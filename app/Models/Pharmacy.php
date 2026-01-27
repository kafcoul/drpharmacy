<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Pharmacy extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'phone',
        'email',
        'address',
        'city',
        'region',
        'duty_zone_id',
        'latitude',
        'longitude',
        'status',
        'is_featured',
        'commission_rate_platform',
        'commission_rate_pharmacy',
        'commission_rate_courier',
        'license_number',
        'license_document',
        'id_card_document',
        'owner_name',
        'rejection_reason',
        'approved_at',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'commission_rate_platform' => 'decimal:4',
        'commission_rate_pharmacy' => 'decimal:4',
        'commission_rate_courier' => 'decimal:4',
        'approved_at' => 'datetime',
        'is_featured' => 'boolean',
    ];

    /**
     * Relation vers la zone de service
     */
    public function dutyZone(): BelongsTo
    {
        return $this->belongsTo(DutyZone::class);
    }

    /**
     * Portefeuille de la pharmacie
     */
    public function wallet(): MorphOne
    {
        return $this->morphOne(Wallet::class, 'walletable');
    }
    
    /**
     * Utilisateurs liés à cette pharmacie
     */
    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'pharmacy_user')
            ->withPivot('role')
            ->withTimestamps();
    }

    /**
     * Commandes de cette pharmacie
     */
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    /**
     * Vérifier si la pharmacie est approuvée
     */
    public function isApproved(): bool
    {
        return $this->status === 'approved';
    }

    /**
     * Scope: pharmacies approuvées
     */
    public function scopeApproved($query)
    {
        return $query->where('status', 'approved');
    }

    /**
     * Scope: pharmacies en attente
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Scope: pharmacies proches d'une position
     */
    public function scopeNearLocation($query, $latitude, $longitude, $radiusKm = 10)
    {
        $earthRadius = 6371; // km

        return $query->selectRaw("
                *,
                (
                    {$earthRadius} * acos(
                        cos(radians(?)) * cos(radians(latitude)) *
                        cos(radians(longitude) - radians(?)) +
                        sin(radians(?)) * sin(radians(latitude))
                    )
                ) AS distance
            ", [$latitude, $longitude, $latitude])
            ->having('distance', '<=', $radiusKm)
            ->orderBy('distance');
    }

    /**
     * Gardes de cette pharmacie
     */
    public function onCalls(): HasMany
    {
        return $this->hasMany(PharmacyOnCall::class);
    }

    /**
     * Scope: pharmacies de garde actuellement
     */
    public function scopeOnDuty($query)
    {
        return $query->whereHas('onCalls', function ($q) {
            $q->where('start_at', '<=', now())
              ->where('end_at', '>=', now())
              ->where('is_active', true);
        });
    }

    /**
     * Scope: pharmacies en vedette
     */
    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    /**
     * Informations de paiement de la pharmacie
     */
    public function paymentInfo(): HasMany
    {
        return $this->hasMany(PaymentInfo::class);
    }

    /**
     * Demandes de retrait de la pharmacie
     */
    public function withdrawalRequests(): HasMany
    {
        return $this->hasMany(WithdrawalRequest::class);
    }
}

