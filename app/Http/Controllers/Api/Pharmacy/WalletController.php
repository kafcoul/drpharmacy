<?php

namespace App\Http\Controllers\Api\Pharmacy;

use App\Http\Controllers\Controller;
use App\Models\Pharmacy;
use App\Models\WithdrawalRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class WalletController extends Controller
{
    /**
     * Get wallet balance and transaction history
     */
    public function index(Request $request)
    {
        $user = Auth::user();
        
        // Find pharmacy associated with user
        $pharmacy = $user->pharmacies()->firstOrFail();
        
        // Retrieve or create wallet
        $wallet = $pharmacy->wallet()->firstOrCreate([], [
            'currency' => 'XOF',
            'balance' => 0
        ]);
        
        // Get recent transactions
        $transactions = $wallet->transactions()
            ->latest()
            ->limit(30)
            ->get()
            ->map(function ($tx) {
                return [
                    'id' => $tx->id,
                    'amount' => $tx->amount,
                    'type' => $tx->type, // credit/debit
                    'description' => $tx->description,
                    'reference' => $tx->reference,
                    'date' => $tx->created_at->format('d/m/Y H:i'),
                ];
            });
            
        return response()->json([
            'status' => 'success',
            'data' => [
                'balance' => $wallet->balance,
                'currency' => $wallet->currency,
                'transactions' => $transactions,
                'total_earnings' => $transactions->where('type', 'credit')->sum('amount'),
                'total_commission_paid' => $transactions->where('type', 'debit')->sum('amount'),
            ]
        ]);
    }

    /**
     * Get wallet statistics for a period
     */
    public function stats(Request $request)
    {
        $user = Auth::user();
        $pharmacy = $user->pharmacies()->firstOrFail();
        $wallet = $pharmacy->wallet;
        
        if (!$wallet) {
            return response()->json([
                'status' => 'success',
                'data' => [
                    'total_credits' => 0,
                    'total_debits' => 0,
                    'transaction_count' => 0,
                    'average_transaction' => 0,
                    'period' => $request->get('period', 'month'),
                ]
            ]);
        }
        
        $period = $request->get('period', 'month');
        $query = $wallet->transactions();
        
        // Filter by period
        switch ($period) {
            case 'today':
                $query->whereDate('created_at', now());
                break;
            case 'week':
                $query->where('created_at', '>=', now()->startOfWeek());
                break;
            case 'month':
                $query->where('created_at', '>=', now()->startOfMonth());
                break;
            case 'year':
                $query->where('created_at', '>=', now()->startOfYear());
                break;
        }
        
        $transactions = $query->get();
        $totalCredits = $transactions->where('type', 'credit')->sum('amount');
        $totalDebits = $transactions->where('type', 'debit')->sum('amount');
        $count = $transactions->count();
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'total_credits' => $totalCredits,
                'total_debits' => $totalDebits,
                'transaction_count' => $count,
                'average_transaction' => $count > 0 ? ($totalCredits + $totalDebits) / $count : 0,
                'period' => $period,
            ]
        ]);
    }

    /**
     * Request a withdrawal
     */
    public function withdraw(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:1000',
            'payment_method' => 'required|in:bank,mobile_money',
            'account_details' => 'nullable|string',
        ]);
        
        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Donnees invalides',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $user = Auth::user();
        $pharmacy = $user->pharmacies()->firstOrFail();
        $wallet = $pharmacy->wallet;
        
        if (!$wallet || $wallet->balance < $request->amount) {
            return response()->json([
                'status' => 'error',
                'message' => 'Solde insuffisant'
            ], 400);
        }
        
        // Create withdrawal request
        $reference = 'WD-' . strtoupper(Str::random(8));
        
        // Create the withdrawal request record (or transaction with pending status)
        $withdrawal = WithdrawalRequest::create([
            'wallet_id' => $wallet->id,
            'pharmacy_id' => $pharmacy->id,
            'amount' => $request->amount,
            'payment_method' => $request->payment_method,
            'account_details' => $request->account_details,
            'reference' => $reference,
            'status' => 'pending',
        ]);
        
        return response()->json([
            'status' => 'success',
            'message' => 'Demande de retrait enregistree. Traitement sous 24-48h.',
            'data' => [
                'reference' => $reference,
                'status' => 'pending',
                'amount' => $request->amount,
            ]
        ]);
    }

    /**
     * Save bank information
     */
    public function saveBankInfo(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'bank_name' => 'required|string|max:100',
            'holder_name' => 'required|string|max:100',
            'account_number' => 'required|string|max:50',
            'iban' => 'nullable|string|max:50',
        ]);
        
        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Donnees invalides',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $user = Auth::user();
        $pharmacy = $user->pharmacies()->firstOrFail();
        
        // Save or update payment info
        $pharmacy->paymentInfo()->updateOrCreate(
            ['type' => 'bank'],
            [
                'bank_name' => $request->bank_name,
                'holder_name' => $request->holder_name,
                'account_number' => $request->account_number,
                'iban' => $request->iban,
                'is_primary' => true,
            ]
        );
        
        return response()->json([
            'status' => 'success',
            'message' => 'Informations bancaires enregistrees'
        ]);
    }

    /**
     * Save Mobile Money information
     */
    public function saveMobileMoneyInfo(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'operator' => 'required|string|max:50',
            'phone_number' => 'required|string|max:20',
            'account_name' => 'required|string|max:100',
            'is_primary' => 'boolean',
        ]);
        
        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Donnees invalides',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $user = Auth::user();
        $pharmacy = $user->pharmacies()->firstOrFail();
        
        // If this is primary, unset others
        if ($request->get('is_primary', true)) {
            $pharmacy->paymentInfo()->where('type', 'mobile_money')->update(['is_primary' => false]);
        }
        
        // Save or update payment info
        $pharmacy->paymentInfo()->updateOrCreate(
            ['type' => 'mobile_money', 'phone_number' => $request->phone_number],
            [
                'operator' => $request->operator,
                'holder_name' => $request->account_name,
                'is_primary' => $request->get('is_primary', true),
            ]
        );
        
        return response()->json([
            'status' => 'success',
            'message' => 'Informations Mobile Money enregistrees'
        ]);
    }

    /**
     * Set withdrawal threshold
     */
    public function setWithdrawalThreshold(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'threshold' => 'required|numeric|min:10000',
            'auto_withdraw' => 'required|boolean',
        ]);
        
        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Donnees invalides',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $user = Auth::user();
        $pharmacy = $user->pharmacies()->firstOrFail();
        
        $pharmacy->update([
            'withdrawal_threshold' => $request->threshold,
            'auto_withdraw_enabled' => $request->auto_withdraw,
        ]);
        
        return response()->json([
            'status' => 'success',
            'message' => 'Seuil de retrait configure'
        ]);
    }

    /**
     * Export transactions
     */
    public function exportTransactions(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'format' => 'required|in:pdf,excel,csv',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);
        
        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Donnees invalides',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $user = Auth::user();
        $pharmacy = $user->pharmacies()->firstOrFail();
        $wallet = $pharmacy->wallet;
        
        if (!$wallet) {
            return response()->json([
                'status' => 'error',
                'message' => 'Aucun portefeuille trouve'
            ], 404);
        }
        
        // Get transactions for the period
        $transactions = $wallet->transactions()
            ->whereBetween('created_at', [$request->start_date, $request->end_date])
            ->orderBy('created_at', 'desc')
            ->get();
        
        // For now, return a placeholder URL (in production, generate actual file)
        $filename = 'releve_' . now()->format('Y-m-d') . '.' . $request->format;
        
        return response()->json([
            'status' => 'success',
            'message' => 'Export genere',
            'download_url' => url('/exports/' . $filename),
            'transaction_count' => $transactions->count(),
        ]);
    }
}
