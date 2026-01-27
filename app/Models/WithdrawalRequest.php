<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WithdrawalRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'wallet_id',
        'pharmacy_id',
        'amount',
        'payment_method',
        'account_details',
        'reference',
        'status',
        'processed_at',
        'admin_notes',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'processed_at' => 'datetime',
    ];

    /**
     * Get the wallet that owns this withdrawal request
     */
    public function wallet()
    {
        return $this->belongsTo(Wallet::class);
    }

    /**
     * Get the pharmacy that owns this withdrawal request
     */
    public function pharmacy()
    {
        return $this->belongsTo(Pharmacy::class);
    }

    /**
     * Scope for pending requests
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Scope for completed requests
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    /**
     * Mark as processed
     */
    public function markAsProcessed($notes = null)
    {
        $this->update([
            'status' => 'completed',
            'processed_at' => now(),
            'admin_notes' => $notes,
        ]);
    }

    /**
     * Mark as rejected
     */
    public function markAsRejected($reason)
    {
        $this->update([
            'status' => 'rejected',
            'processed_at' => now(),
            'admin_notes' => $reason,
        ]);
    }
}
