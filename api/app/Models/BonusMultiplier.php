<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BonusMultiplier extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'type',
        'multiplier',
        'flat_bonus',
        'conditions',
        'is_active',
        'starts_at',
        'ends_at',
    ];

    protected $casts = [
        'multiplier' => 'float',
        'flat_bonus' => 'integer',
        'conditions' => 'array',
        'is_active' => 'boolean',
        'starts_at' => 'datetime',
        'ends_at' => 'datetime',
    ];

    /**
     * Scope: Active bonuses only
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true)
            ->where(function ($q) {
                $q->whereNull('starts_at')
                    ->orWhere('starts_at', '<=', now());
            })
            ->where(function ($q) {
                $q->whereNull('ends_at')
                    ->orWhere('ends_at', '>=', now());
            });
    }

    /**
     * Check if bonus applies at current time
     */
    public function appliesNow(): bool
    {
        if (!$this->is_active) return false;
        
        if ($this->starts_at && $this->starts_at->isFuture()) return false;
        if ($this->ends_at && $this->ends_at->isPast()) return false;

        // Check time-based conditions
        if ($this->type === 'time_based' && $this->conditions) {
            $currentHour = now()->hour;
            $startHour = $this->conditions['start_hour'] ?? 0;
            $endHour = $this->conditions['end_hour'] ?? 24;
            
            if ($currentHour < $startHour || $currentHour >= $endHour) {
                return false;
            }
        }

        return true;
    }

    /**
     * Calculate bonus for a given base amount
     */
    public function calculateBonus(float $baseAmount): float
    {
        $multipliedAmount = $baseAmount * $this->multiplier;
        return ($multipliedAmount - $baseAmount) + $this->flat_bonus;
    }
}
