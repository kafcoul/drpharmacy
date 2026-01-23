<?php

namespace App\Http\Controllers\Api\Courier;

use App\Http\Controllers\Controller;
use App\Models\Courier;
use App\Services\ChallengeService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ChallengeController extends Controller
{
    public function __construct(
        private ChallengeService $challengeService
    ) {}

    /**
     * Get available challenges and progress
     * GET /api/courier/challenges
     */
    public function index(Request $request)
    {
        $user = Auth::user();
        $courier = Courier::where('user_id', $user->id)->first();

        if (!$courier) {
            return response()->json([
                'status' => 'error',
                'message' => 'Profil coursier non trouvé'
            ], 404);
        }

        $challenges = $this->challengeService->getAvailableChallenges($courier);
        $activeBonuses = $this->challengeService->getActiveBonuses();

        // Séparer par statut
        $inProgress = array_filter($challenges, fn($c) => $c['status'] === 'in_progress');
        $completed = array_filter($challenges, fn($c) => $c['status'] === 'completed');
        $rewarded = array_filter($challenges, fn($c) => $c['status'] === 'rewarded');

        return response()->json([
            'status' => 'success',
            'data' => [
                'challenges' => [
                    'in_progress' => array_values($inProgress),
                    'completed' => array_values($completed),
                    'rewarded' => array_values($rewarded),
                    'all' => $challenges,
                ],
                'active_bonuses' => $activeBonuses,
                'stats' => [
                    'total_challenges' => count($challenges),
                    'in_progress_count' => count($inProgress),
                    'completed_count' => count($completed),
                    'rewarded_count' => count($rewarded),
                    'can_claim_count' => count(array_filter($challenges, fn($c) => $c['can_claim'])),
                ],
            ],
        ]);
    }

    /**
     * Claim reward for a completed challenge
     * POST /api/courier/challenges/{id}/claim
     */
    public function claimReward(Request $request, int $challengeId)
    {
        $user = Auth::user();
        $courier = Courier::where('user_id', $user->id)->first();

        if (!$courier) {
            return response()->json([
                'status' => 'error',
                'message' => 'Profil coursier non trouvé'
            ], 404);
        }

        try {
            $result = $this->challengeService->claimReward($courier, $challengeId);

            return response()->json([
                'status' => 'success',
                'message' => $result['message'],
                'data' => [
                    'reward_amount' => $result['reward_amount'],
                    'transaction_id' => $result['transaction_id'],
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Get active bonuses
     * GET /api/courier/bonuses
     */
    public function bonuses()
    {
        $activeBonuses = $this->challengeService->getActiveBonuses();

        return response()->json([
            'status' => 'success',
            'data' => $activeBonuses,
        ]);
    }

    /**
     * Calculate potential bonus for a delivery
     * POST /api/courier/bonuses/calculate
     */
    public function calculateBonus(Request $request)
    {
        $request->validate([
            'base_earnings' => 'required|numeric|min:0',
        ]);

        $result = $this->challengeService->calculateDeliveryBonus($request->base_earnings);

        return response()->json([
            'status' => 'success',
            'data' => $result,
        ]);
    }
}
