<?php

namespace App\Http\Controllers\Api\Courier;

use App\Http\Controllers\Controller;
use App\Models\Delivery;
use App\Models\WalletTransaction;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StatisticsController extends Controller
{
    /**
     * Get comprehensive statistics for the courier
     * 
     * GET /api/courier/statistics
     * Query params: period (today, week, month, year)
     */
    public function index(Request $request)
    {
        $courier = $request->user()->courier; // Get Courier profile, not User
        
        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        $period = $request->input('period', 'week');
        
        // Determine date range
        $startDate = $this->getStartDate($period);
        $endDate = Carbon::now();
        
        // Get deliveries for period
        $deliveries = Delivery::where('courier_id', $courier->id)
            ->whereBetween('created_at', [$startDate, $endDate])
            ->get();
        
        // Calculate statistics
        $stats = [
            'period' => $period,
            'start_date' => $startDate->toDateString(),
            'end_date' => $endDate->toDateString(),
            
            // Overview
            'overview' => $this->getOverviewStats($deliveries, $courier, $startDate, $endDate),
            
            // Performance metrics
            'performance' => $this->getPerformanceStats($courier),
            
            // Daily breakdown
            'daily_breakdown' => $this->getDailyBreakdown($courier, $startDate, $endDate),
            
            // Peak hours
            'peak_hours' => $this->getPeakHours($courier),
            
            // Revenue breakdown
            'revenue_breakdown' => $this->getRevenueBreakdown($courier, $startDate, $endDate),
            
            // Goals
            'goals' => $this->getGoals($courier),
        ];
        
        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }

    /**
     * Get start date based on period
     */
    private function getStartDate(string $period): Carbon
    {
        return match($period) {
            'today' => Carbon::today(),
            'week' => Carbon::now()->startOfWeek(),
            'month' => Carbon::now()->startOfMonth(),
            'year' => Carbon::now()->startOfYear(),
            default => Carbon::now()->startOfWeek(),
        };
    }

    /**
     * Get overview statistics
     */
    private function getOverviewStats($deliveries, $courier, $startDate, $endDate): array
    {
        $completedDeliveries = $deliveries->where('status', 'delivered');
        $totalDeliveries = $completedDeliveries->count();
        
        // Calculate total earnings
        $totalEarnings = WalletTransaction::whereHas('wallet', function ($query) use ($courier) {
                $query->where('walletable_id', $courier->id)
                      ->where('walletable_type', get_class($courier));
            })
            ->where('type', 'credit')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->sum('amount');
        
        // Calculate total distance and duration
        $totalDistance = $completedDeliveries->sum('distance_km') ?? 0;
        
        $totalDurationMinutes = 0;
        foreach ($completedDeliveries as $delivery) {
            if ($delivery->picked_up_at && $delivery->delivered_at) {
                $totalDurationMinutes += $delivery->delivered_at->diffInMinutes($delivery->picked_up_at);
            } elseif ($delivery->estimated_duration) {
                $totalDurationMinutes += $delivery->estimated_duration;
            }
        }
        
        // Get average rating
        $avgRating = $courier->average_rating ?? 0.0;
        
        // Calculate trends (compare with previous period)
        $previousStart = $startDate->copy()->sub($startDate->diffAsCarbonInterval($endDate));
        $previousDeliveries = Delivery::where('courier_id', $courier->id)
            ->where('status', 'delivered')
            ->whereBetween('created_at', [$previousStart, $startDate])
            ->count();
        
        $deliveryTrend = $previousDeliveries > 0 
            ? round((($totalDeliveries - $previousDeliveries) / $previousDeliveries) * 100, 1)
            : 0;

        // Calculate earnings trend
        $previousEarnings = WalletTransaction::whereHas('wallet', function ($query) use ($courier) {
                $query->where('walletable_id', $courier->id)
                      ->where('walletable_type', get_class($courier));
            })
            ->where('type', 'credit')
            ->whereBetween('created_at', [$previousStart, $startDate])
            ->sum('amount');
            
        $earningsTrend = $previousEarnings > 0 
            ? round((($totalEarnings - $previousEarnings) / $previousEarnings) * 100, 1)
            : 0;
        
        return [
            'total_deliveries' => $totalDeliveries,
            'total_earnings' => round($totalEarnings, 0),
            'total_distance_km' => round($totalDistance, 1),
            'total_duration_minutes' => (int) round($totalDurationMinutes),
            'average_rating' => round($avgRating, 1),
            'delivery_trend' => $deliveryTrend,
            'earnings_trend' => $earningsTrend,
            'currency' => 'FCFA',
        ];
    }

    /**
     * Get performance metrics
     */
    private function getPerformanceStats($courier): array
    {
        $totalAssigned = Delivery::where('courier_id', $courier->id)->count();
        $totalAccepted = Delivery::where('courier_id', $courier->id)
            ->whereIn('status', ['assigned', 'picked_up', 'in_transit', 'delivered'])
            ->count();
        $totalDelivered = Delivery::where('courier_id', $courier->id)
            ->where('status', 'delivered')
            ->count();
        $totalCancelled = Delivery::where('courier_id', $courier->id)
            ->where('status', 'cancelled')
            ->count();
        
        // Calculate on-time rate (based on estimated duration + 15 min buffer)
        $deliveredItems = Delivery::where('courier_id', $courier->id)
            ->where('status', 'delivered')
            ->whereNotNull('delivered_at')
            ->whereNotNull('picked_up_at')
            ->whereNotNull('estimated_duration')
            ->get();
            
        $onTimeCount = $deliveredItems->filter(function($delivery) {
             $expectedTime = $delivery->picked_up_at->copy()->addMinutes($delivery->estimated_duration + 15);
             return $delivery->delivered_at <= $expectedTime;
        })->count();
        
        $onTimeRate = $deliveredItems->count() > 0 
            ? round($onTimeCount / $deliveredItems->count(), 2) 
            : 1.0;
        
        // Customer satisfaction (from ratings)
        $satisfactionRate = $courier->average_rating ? round($courier->average_rating / 5, 2) : 1.0;
        
        return [
            'total_assigned' => $totalAssigned,
            'total_accepted' => $totalAccepted,
            'total_delivered' => $totalDelivered,
            'total_cancelled' => $totalCancelled,
            'acceptance_rate' => $totalAssigned > 0 ? round($totalAccepted / $totalAssigned, 2) : 0,
            'completion_rate' => $totalAccepted > 0 ? round($totalDelivered / $totalAccepted, 2) : 0,
            'cancellation_rate' => $totalAssigned > 0 ? round($totalCancelled / $totalAssigned, 2) : 0,
            'on_time_rate' => $onTimeRate,
            'satisfaction_rate' => $satisfactionRate,
        ];
    }

    /**
     * Get daily breakdown for charts
     */
    private function getDailyBreakdown($courier, $startDate, $endDate): array
    {
        $breakdown = [];
        $currentDate = $startDate->copy();
        
        while ($currentDate <= $endDate) {
            $dayDeliveries = Delivery::where('courier_id', $courier->id)
                ->where('status', 'delivered')
                ->whereDate('created_at', $currentDate)
                ->count();
            
            $dayEarnings = WalletTransaction::whereHas('wallet', function ($query) use ($courier) {
                    $query->where('walletable_id', $courier->id)
                          ->where('walletable_type', get_class($courier));
                })
                ->where('type', 'credit')
                ->whereDate('created_at', $currentDate)
                ->sum('amount');
            
            $breakdown[] = [
                'date' => $currentDate->toDateString(),
                'day_name' => $currentDate->locale('fr')->shortDayName,
                'deliveries' => $dayDeliveries,
                'earnings' => round($dayEarnings, 0),
            ];
            
            $currentDate->addDay();
        }
        
        return $breakdown;
    }

    /**
     * Get peak hours analysis
     */
    private function getPeakHours($courier): array
    {
        // Get all delivered orders with timestamps
        $deliveries = Delivery::where('courier_id', $courier->id)
            ->where('status', 'delivered')
            ->get(['created_at']);
        
        // Count by hour manually (SQLite compatible)
        $hourlyCounts = [];
        foreach ($deliveries as $delivery) {
            $hour = (int) $delivery->created_at->format('H');
            $hourlyCounts[$hour] = ($hourlyCounts[$hour] ?? 0) + 1;
        }
        
        $maxCount = 0;
        $totalCount = 0;
        
        // First pass to calculate counts
        $tempHours = [];
        for ($h = 8; $h <= 22; $h += 2) {
            $count = ($hourlyCounts[$h] ?? 0) + ($hourlyCounts[$h + 1] ?? 0);
            $totalCount += $count;
            if ($count > $maxCount) $maxCount = $count;
            
            $tempHours[] = [
                'hour' => sprintf('%02d:00', $h),
                'label' => "{$h}h",
                'count' => $count,
                // 'is_peak' temporarily omitted or calculated later
            ];
        }
        
        // Second pass to add percentage and build final array
        $hours = [];
        foreach ($tempHours as $item) {
            $item['percentage'] = $totalCount > 0 ? round(($item['count'] / $totalCount) * 100, 1) : 0;
            $item['is_peak'] = $maxCount > 0 && $item['count'] >= ($maxCount * 0.8);
            $hours[] = $item;
        }
        
        return $hours;
    }

    /**
     * Get revenue breakdown by source
     */
    private function getRevenueBreakdown($courier, $startDate, $endDate): array
    {
        $walletId = DB::table('wallets')
            ->where('walletable_id', $courier->id)
            ->where('walletable_type', get_class($courier))
            ->value('id');
        
        if (!$walletId) {
            return [
                'delivery_commissions' => ['amount' => 0, 'percentage' => 0],
                'challenge_bonuses' => ['amount' => 0, 'percentage' => 0],
                'rush_bonuses' => ['amount' => 0, 'percentage' => 0],
                'total' => 0,
            ];
        }
        
        // Commissions from deliveries
        $deliveryCommissions = WalletTransaction::where('wallet_id', $walletId)
            ->where('type', 'credit')
            ->where('category', 'commission')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->sum('amount');
        
        // Challenge bonuses
        $challengeBonuses = WalletTransaction::where('wallet_id', $walletId)
            ->where('type', 'credit')
            ->where('category', 'bonus')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->sum('amount');
        
        // Rush hour bonuses (could be a separate category)
        $rushBonuses = WalletTransaction::where('wallet_id', $walletId)
            ->where('type', 'credit')
            ->where('category', 'rush_bonus')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->sum('amount');
        
        $total = $deliveryCommissions + $challengeBonuses + $rushBonuses;
        
        return [
            'delivery_commissions' => [
                'amount' => round($deliveryCommissions, 0),
                'percentage' => $total > 0 ? round(($deliveryCommissions / $total) * 100, 0) : 0,
            ],
            'challenge_bonuses' => [
                'amount' => round($challengeBonuses, 0),
                'percentage' => $total > 0 ? round(($challengeBonuses / $total) * 100, 0) : 0,
            ],
            'rush_bonuses' => [
                'amount' => round($rushBonuses, 0),
                'percentage' => $total > 0 ? round(($rushBonuses / $total) * 100, 0) : 0,
            ],
            'total' => round($total, 0),
        ];
    }

    /**
     * Get monthly goals and progress
     */
    private function getGoals($courier): array
    {
        $startOfMonth = Carbon::now()->startOfMonth();
        $endOfMonth = Carbon::now()->endOfMonth();
        
        // Current month earnings
        $currentEarnings = WalletTransaction::whereHas('wallet', function ($query) use ($courier) {
                $query->where('walletable_id', $courier->id)
                      ->where('walletable_type', get_class($courier));
            })
            ->where('type', 'credit')
            ->whereBetween('created_at', [$startOfMonth, $endOfMonth])
            ->sum('amount');
        
        // Monthly goal (from courier profile if set)
        $monthlyGoal = $courier->monthly_goal ?? 0;
        
        // Current month deliveries
        $currentDeliveries = Delivery::where('courier_id', $courier->id)
            ->where('status', 'delivered')
            ->whereBetween('created_at', [$startOfMonth, $endOfMonth])
            ->count();
        
        $deliveryGoal = $courier->delivery_goal ?? 0;
        
        // Flatten structure for mobile app compatibility
        // Prioritize delivery goals for the "weeklyTarget" field in current mobile model
        return [
            'weekly_target' => $deliveryGoal,
            'current_progress' => $currentDeliveries,
            'progress_percentage' => $deliveryGoal > 0 ? round(($currentDeliveries / $deliveryGoal) * 100, 1) : 0,
            'remaining' => max(0, $deliveryGoal - $currentDeliveries),
            // Keep detailed data for future use
            'earnings' => [
                'current' => round($currentEarnings, 0),
                'goal' => $monthlyGoal,
                'progress' => $monthlyGoal > 0 ? round(($currentEarnings / $monthlyGoal) * 100, 0) : 0,
            ],
        ];
    }

    /**
     * Get leaderboard position
     * 
     * GET /api/courier/statistics/leaderboard
     */
    public function leaderboard(Request $request)
    {
        $period = $request->input('period', 'week');
        $startDate = $this->getStartDate($period);
        $courier = $request->user();
        
        // Get top couriers by deliveries
        $topCouriers = Delivery::where('status', 'delivered')
            ->where('created_at', '>=', $startDate)
            ->selectRaw('courier_id, COUNT(*) as total_deliveries')
            ->groupBy('courier_id')
            ->orderByDesc('total_deliveries')
            ->limit(10)
            ->get();
        
        // Find current courier's position
        $allRanked = Delivery::where('status', 'delivered')
            ->where('created_at', '>=', $startDate)
            ->selectRaw('courier_id, COUNT(*) as total_deliveries')
            ->groupBy('courier_id')
            ->orderByDesc('total_deliveries')
            ->get();
        
        $position = $allRanked->search(function ($item) use ($courier) {
            return $item->courier_id === $courier->id;
        });
        
        return response()->json([
            'success' => true,
            'data' => [
                'period' => $period,
                'your_position' => $position !== false ? $position + 1 : null,
                'total_couriers' => $allRanked->count(),
                'top_couriers' => $topCouriers->map(function ($item, $index) {
                    return [
                        'rank' => $index + 1,
                        'courier_id' => $item->courier_id,
                        'total_deliveries' => $item->total_deliveries,
                    ];
                }),
            ],
        ]);
    }
}
