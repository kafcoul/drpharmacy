<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Challenge extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'type',
        'metric',
        'target_value',
        'reward_amount',
        'icon',
        'color',
        'is_active',
        'starts_at',
        'ends_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'target_value' => 'integer',
        'reward_amount' => 'integer',
        'starts_at' => 'datetime',
        'ends_at' => 'datetime',
    ];

    /**
     * Couriers participating in this challenge
     */
    public function couriers(): BelongsToMany
    {
        return $this->belongsToMany(Courier::class, 'courier_challenges')
            ->withPivot(['current_progress', 'status', 'started_at', 'completed_at', 'rewarded_at'])
            ->withTimestamps();
    }

    /**
     * Scope: Active challenges only
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
     * Scope: By type
     */
    public function scopeOfType($query, string $type)
    {
        return $query->where('type', $type);
    }

    /**
     * Check if challenge is currently available
     */
    public function isAvailable(): bool
    {
        if (!$this->is_active) return false;
        
        if ($this->starts_at && $this->starts_at->isFuture()) return false;
        if ($this->ends_at && $this->ends_at->isPast()) return false;
        
        return true;
    }

    /**
     * Get icon name for Flutter
     */
    public function getIconNameAttribute(): string
    {
        return match ($this->icon) {
            'star' => 'star',
            'fire' => 'local_fire_department',
            'speed' => 'speed',
            'trophy' => 'emoji_events',
            'calendar' => 'calendar_today',
            'rocket' => 'rocket_launch',
            'crown' => 'military_tech',
            'medal' => 'workspace_premium',
            default => 'star',
        };
    }
}
