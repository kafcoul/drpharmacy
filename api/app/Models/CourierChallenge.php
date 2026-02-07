<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CourierChallenge extends Model
{
    use HasFactory;

    protected $fillable = [
        'courier_id',
        'challenge_id',
        'current_progress',
        'status',
        'started_at',
        'completed_at',
        'rewarded_at',
    ];

    protected $casts = [
        'current_progress' => 'integer',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
        'rewarded_at' => 'datetime',
    ];

    public function courier(): BelongsTo
    {
        return $this->belongsTo(Courier::class);
    }

    public function challenge(): BelongsTo
    {
        return $this->belongsTo(Challenge::class);
    }

    /**
     * Calculate progress percentage
     */
    public function getProgressPercentAttribute(): float
    {
        if (!$this->challenge) return 0;
        return min(100, ($this->current_progress / $this->challenge->target_value) * 100);
    }

    /**
     * Check if challenge is completed
     */
    public function isCompleted(): bool
    {
        return $this->status === 'completed' || $this->status === 'rewarded';
    }

    /**
     * Mark as completed
     */
    public function markCompleted(): void
    {
        $this->update([
            'status' => 'completed',
            'completed_at' => now(),
        ]);
    }

    /**
     * Mark as rewarded
     */
    public function markRewarded(): void
    {
        $this->update([
            'status' => 'rewarded',
            'rewarded_at' => now(),
        ]);
    }

    /**
     * Increment progress
     */
    public function incrementProgress(int $amount = 1): void
    {
        $this->increment('current_progress', $amount);
        
        // Check if completed
        if ($this->current_progress >= $this->challenge->target_value && $this->status === 'in_progress') {
            $this->markCompleted();
        }
    }
}
