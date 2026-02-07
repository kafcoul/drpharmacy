<?php

namespace App\Filament\Widgets;

use App\Models\PharmacyOnCall;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Database\Eloquent\Builder;

class CurrentOnDutyPharmaciesWidget extends BaseWidget
{
    protected static ?string $heading = '🚨 Pharmacies de Garde en ce moment';
    
    protected static ?int $sort = 3;

    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                PharmacyOnCall::query()
                    ->with(['pharmacy', 'dutyZone'])
                    ->where('is_active', true)
                    ->where('start_at', '<=', now())
                    ->where('end_at', '>=', now())
                    ->orderBy('end_at', 'asc')
            )
            ->columns([
                Tables\Columns\TextColumn::make('pharmacy.name')
                    ->label('Pharmacie')
                    ->weight('bold')
                    ->searchable(),
                Tables\Columns\TextColumn::make('pharmacy.phone')
                    ->label('Téléphone')
                    ->icon('heroicon-o-phone')
                    ->copyable(),
                Tables\Columns\TextColumn::make('pharmacy.address')
                    ->label('Adresse')
                    ->limit(30),
                Tables\Columns\TextColumn::make('dutyZone.name')
                    ->label('Zone')
                    ->badge()
                    ->color('info'),
                Tables\Columns\TextColumn::make('type')
                    ->label('Type')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'night' => '🌙 Nuit',
                        'weekend' => '📅 Week-end',
                        'holiday' => '🎉 Férié',
                        'emergency' => '🚨 Urgence',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'night' => 'primary',
                        'weekend' => 'success',
                        'holiday' => 'warning',
                        'emergency' => 'danger',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('end_at')
                    ->label('Fin de garde')
                    ->dateTime('d/m H:i')
                    ->sortable()
                    ->description(fn (PharmacyOnCall $record): string => 
                        'Dans ' . now()->diffForHumans($record->end_at, ['parts' => 2, 'short' => true])
                    ),
            ])
            ->defaultSort('end_at', 'asc')
            ->paginated([5, 10, 25])
            ->emptyStateHeading('Aucune pharmacie de garde')
            ->emptyStateDescription('Aucune pharmacie n\'est actuellement en service de garde.')
            ->emptyStateIcon('heroicon-o-shield-exclamation');
    }
}
