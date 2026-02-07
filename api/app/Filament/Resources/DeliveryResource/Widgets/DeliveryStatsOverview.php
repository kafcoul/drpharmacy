<?php

namespace App\Filament\Resources\DeliveryResource\Widgets;

use App\Models\Delivery;
use App\Models\Courier;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class DeliveryStatsOverview extends BaseWidget
{
    protected static ?string $pollingInterval = '30s';
    
    protected function getStats(): array
    {
        $today = now()->toDateString();
        
        $pendingCount = Delivery::where('status', 'pending')->count();
        $inProgressCount = Delivery::whereIn('status', ['assigned', 'accepted', 'picked_up', 'in_transit'])->count();
        $deliveredTodayCount = Delivery::where('status', 'delivered')
            ->whereDate('delivered_at', $today)
            ->count();
        $availableCouriers = Courier::where('status', 'available')->count();
        $busyCouriers = Courier::where('status', 'busy')->count();
        
        return [
            Stat::make('⏳ En attente', $pendingCount)
                ->description('Livraisons non assignées')
                ->descriptionIcon('heroicon-o-clock')
                ->color($pendingCount > 5 ? 'danger' : ($pendingCount > 0 ? 'warning' : 'success'))
                ->chart([7, 3, 4, 5, 6, $pendingCount]),
            
            Stat::make('🚚 En cours', $inProgressCount)
                ->description('Assignées ou en livraison')
                ->descriptionIcon('heroicon-o-truck')
                ->color('info')
                ->chart([2, 4, 6, 3, 5, $inProgressCount]),
            
            Stat::make('✅ Livrées aujourd\'hui', $deliveredTodayCount)
                ->description('Livraisons terminées')
                ->descriptionIcon('heroicon-o-check-circle')
                ->color('success')
                ->chart([1, 3, 5, 7, 4, $deliveredTodayCount]),
            
            Stat::make('👤 Livreurs disponibles', "{$availableCouriers} / " . ($availableCouriers + $busyCouriers))
                ->description($busyCouriers . ' en course')
                ->descriptionIcon('heroicon-o-users')
                ->color($availableCouriers > 0 ? 'success' : 'danger'),
        ];
    }
}
