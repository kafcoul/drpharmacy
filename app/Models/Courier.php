<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Illuminate\Database\Eloquent\Relations\MorphOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Courier extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'phone',
        'vehicle_type',
        'vehicle_number',
        'license_number',
        // KYC Documents - Recto/Verso
        'id_card_front_document',
        'id_card_back_document',
        'selfie_document',
        'driving_license_front_document',
        'driving_license_back_document',
        'vehicle_registration_document',
        'kyc_status', // incomplete, pending_review, approved, rejected
        'kyc_rejection_reason',
        'kyc_verified_at',
        // Location
        'latitude',
        'longitude',
        'status',
        'rating',
        'completed_deliveries',
        'last_location_update',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'rating' => 'float',
        'completed_deliveries' => 'integer',
        'last_location_update' => 'datetime',
        'kyc_verified_at' => 'datetime',
    ];

    /**
     * Utilisateur associé
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Livraisons du livreur
     */
    public function deliveries(): HasMany
    {
        return $this->hasMany(Delivery::class);
    }
    
    /**
     * Portefeuille du livreur
     */
    public function wallet(): MorphOne
    {
        return $this->morphOne(Wallet::class, 'walletable');
    }

    /**
     * Transactions du portefeuille (via wallet)
     * Retourne un query builder des transactions du wallet du courier
     */
    public function walletTransactions()
    {
        // Get or create wallet first
        $wallet = $this->wallet()->firstOrCreate(
            ['walletable_type' => self::class, 'walletable_id' => $this->id],
            ['balance' => 0, 'currency' => 'XOF']
        );
        
        return WalletTransaction::where('wallet_id', $wallet->id);
    }

    /**
     * Commissions reçues
     */
    public function commissionLines(): MorphMany
    {
        return $this->morphMany(CommissionLine::class, 'actor');
    }

    /**
     * Scope: livreurs disponibles
     */
    public function scopeAvailable($query)
    {
        return $query->where('status', 'available');
    }

    /**
     * Scope: livreurs proches d'une position
     */
    public function scopeNearLocation($query, $latitude, $longitude)
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
            ", [$latitude, $longitude, $latitude]);
    }

    /**
     * Scope: trier par distance
     */
    public function scopeOrderByDistance($query, $latitude, $longitude)
    {
        return $query->nearLocation($latitude, $longitude)
            ->orderBy('distance');
    }

    /**
     * Mettre à jour la position
     */
    public function updateLocation(float $latitude, float $longitude): void
    {
        $this->update([
            'latitude' => $latitude,
            'longitude' => $longitude,
            'last_location_update' => now(),
        ]);
    }
}

