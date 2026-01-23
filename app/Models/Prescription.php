<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Prescription extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'images',
        'notes',
        'status',
        'admin_notes',
        'validated_at',
        'validated_by',
    ];

    protected $casts = [
        'images' => 'array',
        'validated_at' => 'datetime',
    ];

    /**
     * Prescription statuses
     */
    const STATUS_PENDING = 'pending';
    const STATUS_VALIDATED = 'validated';
    const STATUS_REJECTED = 'rejected';

    /**
     * Get the customer that owns the prescription
     */
    public function customer()
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    /**
     * Get the admin who validated the prescription
     */
    public function validator()
    {
        return $this->belongsTo(User::class, 'validated_by');
    }

    /**
     * Scope for pending prescriptions
     */
    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    /**
     * Scope for validated prescriptions
     */
    public function scopeValidated($query)
    {
        return $query->where('status', self::STATUS_VALIDATED);
    }

    /**
     * Check if prescription is pending
     */
    public function isPending(): bool
    {
        return $this->status === self::STATUS_PENDING;
    }

    /**
     * Check if prescription is validated
     */
    public function isValidated(): bool
    {
        return $this->status === self::STATUS_VALIDATED;
    }
}
