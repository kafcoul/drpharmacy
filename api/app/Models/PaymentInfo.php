<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PaymentInfo extends Model
{
    use HasFactory;

    protected $table = 'payment_infos';

    protected $fillable = [
        'pharmacy_id',
        'type', // 'bank' or 'mobile_money'
        'bank_name',
        'holder_name',
        'account_number',
        'iban',
        'operator',
        'phone_number',
        'is_primary',
        'is_verified',
        'verified_at',
    ];

    protected $casts = [
        'is_primary' => 'boolean',
        'is_verified' => 'boolean',
        'verified_at' => 'datetime',
    ];

    /**
     * Get the pharmacy that owns this payment info
     */
    public function pharmacy()
    {
        return $this->belongsTo(Pharmacy::class);
    }

    /**
     * Scope for bank accounts
     */
    public function scopeBank($query)
    {
        return $query->where('type', 'bank');
    }

    /**
     * Scope for mobile money accounts
     */
    public function scopeMobileMoney($query)
    {
        return $query->where('type', 'mobile_money');
    }

    /**
     * Scope for primary accounts
     */
    public function scopePrimary($query)
    {
        return $query->where('is_primary', true);
    }

    /**
     * Get formatted display name
     */
    public function getDisplayNameAttribute()
    {
        if ($this->type === 'bank') {
            return "{$this->bank_name} - ****" . substr($this->account_number, -4);
        }
        return "{$this->operator} - " . substr($this->phone_number, -4);
    }
}
