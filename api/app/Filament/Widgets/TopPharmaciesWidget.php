<?php

namespace App\Filament\Widgets;

use App\Models\Pharmacy;
use App\Models\Order;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Database\Eloquent\Builder;

class TopPharmaciesWidget extends BaseWidget
{
    protected static ?string $heading = '🏆 Top 5 Pharmacies du mois';
    
    protected static ?int $sort = 8;
    
    protected int | string | array $columnSpan = 'half';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Pharmacy::query()
                    ->withCount(['orders' => function (Builder $query) {
                        $query->whereMonth('created_at', now()->month)
                            ->whereYear('created_at', now()->year)
                            ->where('status', 'delivered');
                    }])
                    ->withSum(['orders' => function (Builder $query) {
                        $query->whereMonth('created_at', now()->month)
                            ->whereYear('created_at', now()->year)
                            ->where('status', 'delivered');
                    }], 'total_amount')
                    ->orderByDesc('orders_count')
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
                Tables\Columns\TextColumn::make('name')
                    ->label('Pharmacie')
                    ->searchable()
                    ->limit(20),
                Tables\Columns\TextColumn::make('orders_count')
                    ->label('Commandes')
                    ->badge()
                    ->color('success'),
                Tables\Columns\TextColumn::make('orders_sum_total_amount')
                    ->label('CA')
                    ->money('XOF')
                    ->color('success'),
            ])
            ->paginated(false)
            ->emptyStateHeading('Aucune donnée')
            ->emptyStateDescription('Pas encore de commandes ce mois.');
    }
}
