<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CustomerAddress extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'label',
        'address',
        'city',
        'district',
        'phone',
        'instructions',
        'latitude',
        'longitude',
        'is_default',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'is_default' => 'boolean',
    ];

    /**
     * Labels d'adresse disponibles
     */
    public const LABELS = [
        'Maison',
        'Bureau',
        'Famille',
        'Autre',
    ];

    /**
     * L'utilisateur propriétaire de cette adresse
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Obtenir l'adresse complète formatée
     */
    public function getFullAddressAttribute(): string
    {
        $parts = [$this->address];
        
        if ($this->district) {
            $parts[] = $this->district;
        }
        
        if ($this->city) {
            $parts[] = $this->city;
        }
        
        return implode(', ', $parts);
    }

    /**
     * Vérifier si l'adresse a des coordonnées GPS
     */
    public function hasCoordinates(): bool
    {
        return $this->latitude !== null && $this->longitude !== null;
    }

    /**
     * Définir cette adresse comme adresse par défaut
     */
    public function setAsDefault(): void
    {
        // Retirer is_default des autres adresses de l'utilisateur
        static::where('user_id', $this->user_id)
            ->where('id', '!=', $this->id)
            ->update(['is_default' => false]);
        
        $this->update(['is_default' => true]);
    }

    /**
     * Scope pour les adresses d'un utilisateur
     */
    public function scopeForUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope pour l'adresse par défaut
     */
    public function scopeDefault($query)
    {
        return $query->where('is_default', true);
    }
}
