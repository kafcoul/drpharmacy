<?php

namespace App\Services;

use App\Models\Challenge;
use App\Models\Courier;
use App\Models\CourierChallenge;
use App\Models\BonusMultiplier;
use App\Models\WalletTransaction;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ChallengeService
{
    public function __construct(
        private WalletService $walletService
    ) {}

    /**
     * Get available challenges for a courier
     */
    public function getAvailableChallenges(Courier $courier): array
    {
        $challenges = Challenge::active()->get();
        
        return $challenges->map(function ($challenge) use ($courier) {
            $participation = $this->getCourierParticipation($courier, $challenge);
            
            return [
                'id' => $challenge->id,
                'title' => $challenge->title,
                'description' => $challenge->description,
                'type' => $challenge->type,
                'metric' => $challenge->metric,
                'target_value' => $challenge->target_value,
                'reward_amount' => $challenge->reward_amount,
                'icon' => $challenge->icon_name,
                'color' => $challenge->color,
                'ends_at' => $challenge->ends_at?->toIso8601String(),
                'current_progress' => $participation['current_progress'] ?? 0,
                'progress_percent' => $participation['progress_percent'] ?? 0,
                'status' => $participation['status'] ?? 'available',
                'can_claim' => $participation['can_claim'] ?? false,
            ];
        })->toArray();
    }

    /**
     * Get courier participation in a challenge
     */
    public function getCourierParticipation(Courier $courier, Challenge $challenge): array
    {
        // Get or create participation based on challenge type
        $participation = $this->getOrCreateParticipation($courier, $challenge);
        
        if (!$participation) {
            return [
                'current_progress' => 0,
                'progress_percent' => 0,
                'status' => 'available',
                'can_claim' => false,
            ];
        }

        return [
            'id' => $participation->id,
            'current_progress' => $participation->current_progress,
            'progress_percent' => $participation->progress_percent,
            'status' => $participation->status,
            'can_claim' => $participation->status === 'completed',
            'started_at' => $participation->started_at?->toIso8601String(),
            'completed_at' => $participation->completed_at?->toIso8601String(),
        ];
    }

    /**
     * Get or create participation record for periodic challenges
     */
    private function getOrCreateParticipation(Courier $courier, Challenge $challenge): ?CourierChallenge
    {
        $periodStart = $this->getPeriodStart($challenge->type);
        
        // Check for existing participation in current period
        $existing = CourierChallenge::where('courier_id', $courier->id)
            ->where('challenge_id', $challenge->id)
            ->where('started_at', '>=', $periodStart)
            ->first();

        if ($existing) {
            return $existing;
        }

        // For one_time challenges, check if already completed ever
        if ($challenge->type === 'one_time' || $challenge->type === 'milestone') {
            $completedBefore = CourierChallenge::where('courier_id', $courier->id)
                ->where('challenge_id', $challenge->id)
                ->whereIn('status', ['completed', 'rewarded'])
                ->exists();
            
            if ($completedBefore) {
                return null; // Can't participate again
            }
        }

        // Auto-create participation for new period
        return CourierChallenge::create([
            'courier_id' => $courier->id,
            'challenge_id' => $challenge->id,
            'current_progress' => $this->calculateCurrentProgress($courier, $challenge, $periodStart),
            'status' => 'in_progress',
            'started_at' => $periodStart,
        ]);
    }

    /**
     * Get period start date based on challenge type
     */
    private function getPeriodStart(string $type): \Carbon\Carbon
    {
        return match ($type) {
            'daily' => now()->startOfDay(),
            'weekly' => now()->startOfWeek(),
            'monthly' => now()->startOfMonth(),
            default => now()->startOfDay(),
        };
    }

    /**
     * Calculate current progress for a metric
     */
    private function calculateCurrentProgress(Courier $courier, Challenge $challenge, \Carbon\Carbon $periodStart): int
    {
        return match ($challenge->metric) {
            'deliveries_count' => $courier->deliveries()
                ->where('status', 'delivered')
                ->where('completed_at', '>=', $periodStart)
                ->count(),
            
            'earnings_amount' => (int) $courier->walletTransactions()
                ->whereIn('category', ['delivery_earning', 'bonus'])
                ->where('created_at', '>=', $periodStart)
                ->sum('amount'),
            
            'consecutive_days' => $this->calculateConsecutiveDays($courier),
            
            'distance_km' => (int) $courier->deliveries()
                ->where('status', 'delivered')
                ->where('completed_at', '>=', $periodStart)
                ->sum('actual_distance'),
            
            default => 0,
        };
    }

    /**
     * Calculate consecutive active days
     */
    private function calculateConsecutiveDays(Courier $courier): int
    {
        $days = 0;
        $checkDate = now()->startOfDay();
        
        while ($days < 365) { // Max 1 year
            $hasDelivery = $courier->deliveries()
                ->where('status', 'delivered')
                ->whereDate('completed_at', $checkDate)
                ->exists();
            
            if (!$hasDelivery) break;
            
            $days++;
            $checkDate = $checkDate->subDay();
        }
        
        return $days;
    }

    /**
     * Update progress after a delivery
     */
    public function onDeliveryCompleted(Courier $courier, float $earnings, float $distance): void
    {
        $challenges = Challenge::active()->get();
        
        foreach ($challenges as $challenge) {
            $participation = $this->getOrCreateParticipation($courier, $challenge);
            
            if (!$participation || $participation->status !== 'in_progress') {
                continue;
            }

            $increment = match ($challenge->metric) {
                'deliveries_count' => 1,
                'earnings_amount' => (int) $earnings,
                'distance_km' => (int) $distance,
                'consecutive_days' => 1, // Will be recalculated
                default => 0,
            };

            if ($increment > 0) {
                // Recalculate for consecutive_days
                if ($challenge->metric === 'consecutive_days') {
                    $participation->current_progress = $this->calculateConsecutiveDays($courier);
                    $participation->save();
                } else {
                    $participation->incrementProgress($increment);
                }
                
                // Check if just completed
                if ($participation->fresh()->status === 'completed') {
                    Log::info("Challenge completed", [
                        'courier_id' => $courier->id,
                        'challenge_id' => $challenge->id,
                        'challenge_title' => $challenge->title,
                    ]);
                }
            }
        }
    }

    /**
     * Claim reward for a completed challenge
     */
    public function claimReward(Courier $courier, int $challengeId): array
    {
        $participation = CourierChallenge::where('courier_id', $courier->id)
            ->where('challenge_id', $challengeId)
            ->where('status', 'completed')
            ->first();

        if (!$participation) {
            throw new \Exception('Challenge non complété ou déjà réclamé');
        }

        $challenge = $participation->challenge;

        return DB::transaction(function () use ($courier, $participation, $challenge) {
            // Credit the reward
            $transaction = $this->walletService->creditBonus(
                $courier,
                $challenge->reward_amount,
                "Bonus challenge: {$challenge->title}"
            );

            // Mark as rewarded
            $participation->markRewarded();

            return [
                'success' => true,
                'message' => "Félicitations ! Vous avez reçu {$challenge->reward_amount} FCFA !",
                'reward_amount' => $challenge->reward_amount,
                'transaction_id' => $transaction->id,
            ];
        });
    }

    /**
     * Get active bonus multipliers
     */
    public function getActiveBonuses(): array
    {
        return BonusMultiplier::active()
            ->get()
            ->filter(fn ($bonus) => $bonus->appliesNow())
            ->map(fn ($bonus) => [
                'id' => $bonus->id,
                'name' => $bonus->name,
                'description' => $bonus->description,
                'type' => $bonus->type,
                'multiplier' => $bonus->multiplier,
                'flat_bonus' => $bonus->flat_bonus,
                'ends_at' => $bonus->ends_at?->toIso8601String(),
            ])
            ->values()
            ->toArray();
    }

    /**
     * Calculate total bonus for a delivery
     */
    public function calculateDeliveryBonus(float $baseEarnings): array
    {
        $activeBonuses = BonusMultiplier::active()
            ->get()
            ->filter(fn ($bonus) => $bonus->appliesNow());

        $totalBonus = 0;
        $appliedBonuses = [];

        foreach ($activeBonuses as $bonus) {
            $bonusAmount = $bonus->calculateBonus($baseEarnings);
            $totalBonus += $bonusAmount;
            
            $appliedBonuses[] = [
                'name' => $bonus->name,
                'amount' => $bonusAmount,
            ];
        }

        return [
            'total_bonus' => $totalBonus,
            'applied_bonuses' => $appliedBonuses,
            'final_earnings' => $baseEarnings + $totalBonus,
        ];
    }
}
