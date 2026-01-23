<?php

namespace App\Http\Controllers\Api\Pharmacy;

use App\Http\Controllers\Controller;
use App\Models\Pharmacy;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

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
                'total_commission_paid' => $transactions->where('type', 'debit')->sum('amount'), // If we debit platform fees later
            ]
        ]);
    }
}
