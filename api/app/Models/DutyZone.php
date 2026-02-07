<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class DutyZone extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'city',
        'description',
        'is_active',
        'latitude',
        'longitude',
        'radius',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'latitude' => 'float',
        'longitude' => 'float',
        'radius' => 'float',
    ];

    public function onCalls(): HasMany
    {
        return $this->hasMany(PharmacyOnCall::class);
    }

    public function pharmacies(): HasMany
    {
        return $this->hasMany(Pharmacy::class);
    }

    /**
     * Get active on-calls for this zone
     */
    public function activeOnCalls(): HasMany
    {
        return $this->onCalls()
            ->where('is_active', true)
            ->where('start_at', '<=', now())
            ->where('end_at', '>=', now());
    }

    /**
     * Get pharmacies currently on duty in this zone
     */
    public function pharmaciesOnDuty()
    {
        return $this->pharmacies()
            ->whereHas('onCalls', function ($query) {
                $query->where('is_active', true)
                    ->where('start_at', '<=', now())
                    ->where('end_at', '>=', now());
            });
    }
}
