<?php

namespace App\Filament\Widgets;

use App\Models\PharmacyOnCall;
use App\Models\DutyZone;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class OnDutyStatsWidget extends BaseWidget
{
    protected ?string $heading = 'Pharmacies de Garde';
    
    protected static ?int $sort = 2;

    protected function getStats(): array
    {
        $now = now();
        
        // Count current on-duty pharmacies
        $currentOnDuty = PharmacyOnCall::where('is_active', true)
            ->where('start_at', '<=', $now)
            ->where('end_at', '>=', $now)
            ->count();

        // Count upcoming scheduled
        $upcoming = PharmacyOnCall::where('is_active', true)
            ->where('start_at', '>', $now)
            ->where('start_at', '<=', $now->copy()->addDays(7))
            ->count();

        // Count active zones
        $activeZones = DutyZone::where('is_active', true)->count();

        // Count ending soon (within 2 hours)
        $endingSoon = PharmacyOnCall::where('is_active', true)
            ->where('start_at', '<=', $now)
            ->where('end_at', '>=', $now)
            ->where('end_at', '<=', $now->copy()->addHours(2))
            ->count();

        return [
            Stat::make('En garde actuellement', $currentOnDuty)
                ->description('Pharmacies de garde en ce moment')
                ->descriptionIcon('heroicon-o-shield-check')
                ->color($currentOnDuty > 0 ? 'success' : 'danger')
                ->chart([7, 3, 4, 5, 6, $currentOnDuty, $currentOnDuty]),
            
            Stat::make('Gardes à venir (7j)', $upcoming)
                ->description('Programmées cette semaine')
                ->descriptionIcon('heroicon-o-calendar')
                ->color('info'),
            
            Stat::make('Zones actives', $activeZones)
                ->description('Zones de garde configurées')
                ->descriptionIcon('heroicon-o-map')
                ->color('primary'),
            
            Stat::make('Fin imminente', $endingSoon)
                ->description('Se terminent dans 2h')
                ->descriptionIcon('heroicon-o-clock')
                ->color($endingSoon > 0 ? 'warning' : 'gray'),
        ];
    }
}
