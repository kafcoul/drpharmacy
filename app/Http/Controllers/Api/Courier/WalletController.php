<?php

namespace App\Http\Controllers\Api\Courier;

use App\Http\Controllers\Controller;
use App\Models\Courier;
use App\Services\WalletService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class WalletController extends Controller
{
    public function __construct(
        private WalletService $walletService
    ) {}

    /**
     * Get wallet balance and transaction history
     * GET /api/courier/wallet
     */
    public function index(Request $request)
    {
        $user = Auth::user();
        $courier = Courier::where('user_id', $user->id)->first();
        
        if (!$courier) {
            return response()->json([
                'status' => 'error',
                'message' => 'Profil coursier non trouvé'
            ], 404);
        }
        
        $balance = $this->walletService->getBalance($courier);
        $stats = $this->walletService->getStatistics($courier);
        $transactions = $this->walletService->getTransactionHistory($courier, 20);
            
        return response()->json([
            'status' => 'success',
            'data' => [
                'balance' => $balance['balance'],
                'currency' => $balance['currency'],
                'pending_payouts' => $balance['pending_withdrawals'],
                'available_balance' => $balance['available_balance'],
                'can_deliver' => $balance['can_deliver'],
                'commission_amount' => $balance['commission_amount'],
                'total_topups' => $stats['total_topups'],
                'total_earnings' => $stats['total_delivery_earnings'],
                'total_commissions' => $stats['total_commissions'],
                'deliveries_count' => $stats['deliveries_count'],
                'transactions' => $transactions->map(function ($tx) {
                    return [
                        'id' => $tx->id,
                        'amount' => (float) $tx->amount,
                        'type' => strtolower($tx->type),
                        'category' => $tx->category,
                        'description' => $tx->description,
                        'reference' => $tx->reference,
                        'status' => $tx->status ?? 'completed',
                        'delivery_id' => $tx->delivery_id,
                        'date' => $tx->created_at->toIso8601String(),
                    ];
                }),
            ]
        ]);
    }

    /**
     * Recharger le wallet
     * POST /api/courier/wallet/topup
     */
    public function topUp(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:500|max:500000',
            'payment_method' => 'required|string|in:orange_money,mtn_momo,wave,card',
            'payment_reference' => 'nullable|string|max:100',
        ]);

        $user = Auth::user();
        $courier = Courier::where('user_id', $user->id)->first();
        
        if (!$courier) {
            return response()->json([
                'status' => 'error',
                'message' => 'Profil coursier non trouvé'
            ], 404);
        }

        try {
            $transaction = $this->walletService->topUp(
                $courier,
                $request->amount,
                $request->payment_method,
                $request->payment_reference
            );

            $balance = $this->walletService->getBalance($courier);

            return response()->json([
                'status' => 'success',
                'message' => 'Rechargement effectué avec succès',
                'data' => [
                    'transaction' => [
                        'id' => $transaction->id,
                        'reference' => $transaction->reference,
                        'amount' => (float) $transaction->amount,
                        'balance_after' => (float) $transaction->balance_after,
                    ],
                    'wallet' => $balance,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Request a payout
     * POST /api/courier/wallet/withdraw
     */
    public function withdraw(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:500',
            'payment_method' => 'required|string|in:orange_money,mtn_momo,wave',
            'phone_number' => 'required|string|regex:/^[0-9]{8,10}$/',
        ]);

        $user = Auth::user();
        $courier = Courier::where('user_id', $user->id)->first();
        
        if (!$courier) {
            return response()->json([
                'status' => 'error',
                'message' => 'Profil coursier non trouvé'
            ], 404);
        }

        try {
            $transaction = $this->walletService->requestWithdrawal(
                $courier,
                $request->amount,
                $request->payment_method,
                $request->phone_number
            );

            $balance = $this->walletService->getBalance($courier);

            return response()->json([
                'status' => 'success',
                'message' => 'Demande de retrait enregistrée. Le traitement peut prendre jusqu\'à 24h.',
                'data' => [
                    'transaction' => [
                        'id' => $transaction->id,
                        'reference' => $transaction->reference,
                        'amount' => (float) $transaction->amount,
                        'status' => $transaction->status,
                    ],
                    'wallet' => $balance,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Vérifier si le coursier peut effectuer une livraison
     * GET /api/courier/wallet/can-deliver
     */
    public function canDeliver(Request $request)
    {
        $user = Auth::user();
        $courier = Courier::where('user_id', $user->id)->first();
        
        if (!$courier) {
            return response()->json([
                'status' => 'error',
                'message' => 'Profil coursier non trouvé'
            ], 404);
        }

        $canDeliver = $this->walletService->canCompleteDelivery($courier);
        $balance = $this->walletService->getBalance($courier);

        return response()->json([
            'status' => 'success',
            'data' => [
                'can_deliver' => $canDeliver,
                'commission_amount' => WalletService::getCommissionAmount(),
                'current_balance' => $balance['balance'],
                'message' => $canDeliver 
                    ? 'Vous pouvez effectuer des livraisons' 
                    : 'Solde insuffisant. Rechargez au moins ' . WalletService::getCommissionAmount() . ' FCFA pour pouvoir livrer.',
            ],
        ]);
    }

    /**
     * Get detailed earnings history with filtering
     * GET /api/courier/wallet/earnings-history
     * 
     * Query params:
     * - period: all, today, week, month
     * - category: all, delivery, commission, bonus, deduction, topup, withdrawal
     * - page: int (default 1)
     * - limit: int (default 30)
     */
    public function earningsHistory(Request $request)
    {
        $user = Auth::user();
        $courier = Courier::where('user_id', $user->id)->first();
        
        if (!$courier) {
            return response()->json([
                'status' => 'error',
                'message' => 'Profil coursier non trouvé'
            ], 404);
        }

        $period = $request->query('period', 'all');
        $category = $request->query('category', 'all');
        $limit = min((int) $request->query('limit', 30), 100);
        $page = max((int) $request->query('page', 1), 1);

        // Base query
        $query = $courier->walletTransactions()->latest();

        // Filter by period
        switch ($period) {
            case 'today':
                $query->whereDate('created_at', today());
                break;
            case 'week':
                $query->where('created_at', '>=', now()->startOfWeek());
                break;
            case 'month':
                $query->where('created_at', '>=', now()->startOfMonth());
                break;
            // 'all' - no date filter
        }

        // Filter by category
        if ($category !== 'all') {
            $query->where('category', $category);
        }

        // Get totals for stats (before pagination)
        $totalsQuery = clone $query;
        $totals = [
            'total_earnings' => (clone $totalsQuery)->whereIn('category', ['delivery', 'bonus', 'delivery_earning'])->sum('amount'),
            'total_commissions' => abs((clone $totalsQuery)->where('category', 'commission')->sum('amount')),
            'total_bonuses' => (clone $totalsQuery)->where('category', 'bonus')->sum('amount'),
            'total_deductions' => abs((clone $totalsQuery)->where('category', 'deduction')->sum('amount')),
        ];
        $totals['net_earnings'] = $totals['total_earnings'] - $totals['total_commissions'] - $totals['total_deductions'];

        // Paginate
        $transactions = $query->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'status' => 'success',
            'data' => [
                'transactions' => $transactions->map(function ($tx) {
                    return [
                        'id' => $tx->id,
                        'amount' => (float) $tx->amount,
                        'type' => strtolower($tx->type),
                        'category' => $tx->category,
                        'description' => $tx->description,
                        'reference' => $tx->reference,
                        'status' => $tx->status ?? 'completed',
                        'delivery_id' => $tx->delivery_id,
                        'balance_after' => (float) ($tx->balance_after ?? 0),
                        'date' => $tx->created_at->toIso8601String(),
                    ];
                }),
                'totals' => $totals,
                'pagination' => [
                    'current_page' => $transactions->currentPage(),
                    'last_page' => $transactions->lastPage(),
                    'per_page' => $transactions->perPage(),
                    'total' => $transactions->total(),
                ],
                'filters' => [
                    'period' => $period,
                    'category' => $category,
                ],
            ],
        ]);
    }
}
