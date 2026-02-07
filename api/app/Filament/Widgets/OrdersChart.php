<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use Carbon\Carbon;
use Filament\Widgets\ChartWidget;

class OrdersChart extends ChartWidget
{
    protected static ?string $heading = 'Commandes (7 derniers jours)';
    
    protected static ?int $sort = 2;
    
    protected int | string | array $columnSpan = 'full';

    protected function getData(): array
    {
        $days = collect(range(6, 0))->map(function ($daysAgo) {
            return Carbon::today()->subDays($daysAgo);
        });

        $orderCounts = $days->map(function ($date) {
            return Order::whereDate('created_at', $date)->count();
        });

        $deliveredCounts = $days->map(function ($date) {
            return Order::whereDate('created_at', $date)
                ->where('status', 'delivered')
                ->count();
        });

        return [
            'datasets' => [
                [
                    'label' => 'Toutes commandes',
                    'data' => $orderCounts->toArray(),
                    'backgroundColor' => 'rgba(59, 130, 246, 0.5)',
                    'borderColor' => 'rgb(59, 130, 246)',
                ],
                [
                    'label' => 'Livrées',
                    'data' => $deliveredCounts->toArray(),
                    'backgroundColor' => 'rgba(34, 197, 94, 0.5)',
                    'borderColor' => 'rgb(34, 197, 94)',
                ],
            ],
            'labels' => $days->map(fn ($date) => $date->format('d/m'))->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }
}
