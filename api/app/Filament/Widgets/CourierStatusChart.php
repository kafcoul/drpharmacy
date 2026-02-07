<?php

namespace App\Filament\Widgets;

use App\Models\Courier;
use Filament\Widgets\ChartWidget;

class CourierStatusChart extends ChartWidget
{
    protected static ?string $heading = 'Statut des coursiers';
    
    protected static ?int $sort = 5;
    
    protected static ?string $maxHeight = '250px';
    
    protected int | string | array $columnSpan = 1;

    protected function getData(): array
    {
        $available = Courier::where('status', 'available')->count();
        $busy = Courier::where('status', 'busy')->count();
        $offline = Courier::where('status', 'offline')->count();
        $suspended = Courier::where('status', 'suspended')->count();

        return [
            'datasets' => [
                [
                    'data' => [$available, $busy, $offline, $suspended],
                    'backgroundColor' => [
                        'rgb(34, 197, 94)',   // Disponible - vert
                        'rgb(59, 130, 246)',  // Occupé - bleu
                        'rgb(156, 163, 175)', // Hors ligne - gris
                        'rgb(239, 68, 68)',   // Suspendu - rouge
                    ],
                ],
            ],
            'labels' => ['Disponibles', 'En course', 'Hors ligne', 'Suspendus'],
        ];
    }

    protected function getType(): string
    {
        return 'doughnut';
    }
    
    protected function getOptions(): array
    {
        return [
            'plugins' => [
                'legend' => [
                    'display' => true,
                    'position' => 'bottom',
                ],
            ],
            'maintainAspectRatio' => true,
        ];
    }
}
