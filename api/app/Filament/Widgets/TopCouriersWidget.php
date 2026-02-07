<?php

namespace App\Filament\Widgets;

use App\Models\Courier;
use App\Models\Delivery;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Database\Eloquent\Builder;

class TopCouriersWidget extends BaseWidget
{
    protected static ?string $heading = '🏆 Top 5 Coursiers du mois';
    
    protected static ?int $sort = 9;
    
    protected int | string | array $columnSpan = 'half';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Courier::query()
                    ->withCount(['deliveries' => function (Builder $query) {
                        $query->whereMonth('created_at', now()->month)
                            ->whereYear('created_at', now()->year)
                            ->where('status', 'completed');
                    }])
                    ->withSum(['deliveries' => function (Builder $query) {
                        $query->whereMonth('created_at', now()->month)
                            ->whereYear('created_at', now()->year)
                            ->where('status', 'completed');
                    }], 'delivery_fee')
                    ->orderByDesc('deliveries_count')
                    ->limit(5)
            )
            ->columns([
                Tables\Columns\TextColumn::make('rank')
                    ->label('#')
                    ->rowIndex()
                    ->formatStateUsing(fn ($state) => match($state) {
                        1 => '🥇',
                        2 => '🥈', 
                        3 => '🥉',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Coursier')
                    ->limit(20),
                Tables\Columns\TextColumn::make('deliveries_count')
                    ->label('Livraisons')
                    ->badge()
                    ->color('info'),
                Tables\Columns\TextColumn::make('deliveries_sum_delivery_fee')
                    ->label('Gains')
                    ->money('XOF')
                    ->color('success'),
                Tables\Columns\IconColumn::make('status')
                    ->label('Statut')
                    ->icon(fn ($state) => match($state) {
                        'available' => 'heroicon-o-check-circle',
                        'busy' => 'heroicon-o-truck',
                        'offline' => 'heroicon-o-minus-circle',
                        default => 'heroicon-o-question-mark-circle',
                    })
                    ->color(fn ($state) => match($state) {
                        'available' => 'success',
                        'busy' => 'info',
                        'offline' => 'gray',
                        default => 'warning',
                    }),
            ])
            ->paginated(false)
            ->emptyStateHeading('Aucune donnée')
            ->emptyStateDescription('Pas encore de livraisons ce mois.');
    }
}
