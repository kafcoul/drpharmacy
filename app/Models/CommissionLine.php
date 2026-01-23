<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;

class CommissionLine extends Model
{
    protected $fillable = [
        'commission_id',
        'actor_type',
        'actor_id',
        'rate',
        'amount',
    ];

    protected $casts = [
        'rate' => 'decimal:4',
        'amount' => 'decimal:2',
    ];

    /**
     * Commission principale
     */
    public function commission(): BelongsTo
    {
        return $this->belongsTo(Commission::class);
    }

    /**
     * Acteur (Pharmacy ou Courier) - polymorphic
     */
    public function actor(): MorphTo
    {
        return $this->morphTo();
    }

    /**
     * Scope: commissions de la plateforme
     */
    public function scopePlatform($query)
    {
        return $query->where('actor_type', 'platform');
    }

    /**
     * Scope: commissions des pharmacies
     */
    public function scopePharmacies($query)
    {
        return $query->where('actor_type', 'App\Models\Pharmacy');
    }

    /**
     * Scope: commissions des livreurs
     */
    public function scopeCouriers($query)
    {
        return $query->where('actor_type', 'App\Models\Courier');
    }
}

