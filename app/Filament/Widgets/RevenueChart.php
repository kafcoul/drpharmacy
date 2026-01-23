<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use Carbon\Carbon;
use Filament\Widgets\ChartWidget;

class RevenueChart extends ChartWidget
{
    protected static ?string $heading = 'Chiffre d\'affaires (30 derniers jours)';
    
    protected static ?int $sort = 3;
    
    protected int | string | array $columnSpan = 'full';

    protected function getData(): array
    {
        $days = collect(range(29, 0))->map(function ($daysAgo) {
            return Carbon::today()->subDays($daysAgo);
        });

        $revenues = $days->map(function ($date) {
            return Order::whereDate('created_at', $date)
                ->where('status', 'delivered')
                ->sum('total_amount');
        });

        return [
            'datasets' => [
                [
                    'label' => 'Revenus (FCFA)',
                    'data' => $revenues->toArray(),
                    'backgroundColor' => 'rgba(34, 197, 94, 0.2)',
                    'borderColor' => 'rgb(34, 197, 94)',
                    'fill' => true,
                    'tension' => 0.3,
                ],
            ],
            'labels' => $days->map(fn ($date) => $date->format('d/m'))->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
