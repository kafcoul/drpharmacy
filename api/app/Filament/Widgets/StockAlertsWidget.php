<?php

namespace App\Filament\Widgets;

use App\Models\Product;
use Carbon\Carbon;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Database\Eloquent\Builder;

class StockAlertsWidget extends BaseWidget
{
    protected static ?string $heading = '⚠️ Alertes de Stock';
    
    protected static ?int $sort = 3;
    
    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Product::query()
                    ->where(function (Builder $query) {
                        // Stock faible ou en rupture
                        $query->where('stock_quantity', '<=', 10)
                              ->where('is_available', true);
                    })
                    ->orWhere(function (Builder $query) {
                        // Expiration proche (30 jours)
                        $query->whereNotNull('expiry_date')
                              ->whereBetween('expiry_date', [Carbon::now(), Carbon::now()->addDays(30)])
                              ->where('stock_quantity', '>', 0);
                    })
                    ->orderByRaw('CASE 
                        WHEN stock_quantity = 0 THEN 0 
                        WHEN expiry_date IS NOT NULL AND expiry_date <= ? THEN 1
                        WHEN stock_quantity <= 5 THEN 2
                        ELSE 3 
                    END', [Carbon::now()->addDays(7)])
            )
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label('Photo')
                    ->circular()
                    ->defaultImageUrl(fn () => asset('images/product-placeholder.png')),
                    
                Tables\Columns\TextColumn::make('name')
                    ->label('Produit')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),
                    
                Tables\Columns\TextColumn::make('pharmacy.name')
                    ->label('Pharmacie')
                    ->searchable()
                    ->toggleable(),
                    
                Tables\Columns\TextColumn::make('category.name')
                    ->label('Catégorie')
                    ->badge()
                    ->color('gray'),
                    
                Tables\Columns\TextColumn::make('stock_quantity')
                    ->label('Stock')
                    ->badge()
                    ->color(fn (Product $record): string => match(true) {
                        $record->stock_quantity == 0 => 'danger',
                        $record->stock_quantity <= 5 => 'warning',
                        $record->stock_quantity <= 10 => 'warning',
                        default => 'success',
                    })
                    ->formatStateUsing(fn (Product $record): string => 
                        $record->stock_quantity == 0 
                            ? 'RUPTURE' 
                            : $record->stock_quantity . ' unités'
                    ),
                    
                Tables\Columns\TextColumn::make('expiry_date')
                    ->label('Expiration')
                    ->date('d/m/Y')
                    ->badge()
                    ->color(fn (Product $record): string => match(true) {
                        $record->expiry_date === null => 'gray',
                        $record->expiry_date <= Carbon::now()->addDays(7) => 'danger',
                        $record->expiry_date <= Carbon::now()->addDays(30) => 'warning',
                        default => 'success',
                    })
                    ->formatStateUsing(function (Product $record): string {
                        if (!$record->expiry_date) return '-';
                        $days = Carbon::now()->diffInDays($record->expiry_date, false);
                        if ($days < 0) return 'EXPIRÉ';
                        if ($days == 0) return "Aujourd'hui";
                        if ($days == 1) return 'Demain';
                        return "Dans {$days}j";
                    }),
                    
                Tables\Columns\TextColumn::make('alert_type')
                    ->label('Type d\'alerte')
                    ->badge()
                    ->getStateUsing(function (Product $record): string {
                        if ($record->stock_quantity == 0) return 'Rupture de stock';
                        if ($record->expiry_date && $record->expiry_date <= Carbon::now()->addDays(7)) return 'Expiration critique';
                        if ($record->expiry_date && $record->expiry_date <= Carbon::now()->addDays(30)) return 'Expiration proche';
                        if ($record->stock_quantity <= 5) return 'Stock critique';
                        return 'Stock faible';
                    })
                    ->color(fn (string $state): string => match($state) {
                        'Rupture de stock' => 'danger',
                        'Expiration critique' => 'danger',
                        'Stock critique' => 'danger',
                        'Expiration proche' => 'warning',
                        'Stock faible' => 'warning',
                        default => 'gray',
                    }),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('alert_type')
                    ->label('Type d\'alerte')
                    ->options([
                        'stock' => 'Problèmes de stock',
                        'expiry' => 'Expiration proche',
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return match($data['value']) {
                            'stock' => $query->where('stock_quantity', '<=', 10),
                            'expiry' => $query->whereNotNull('expiry_date')
                                             ->whereBetween('expiry_date', [Carbon::now(), Carbon::now()->addDays(30)]),
                            default => $query,
                        };
                    }),
                    
                Tables\Filters\SelectFilter::make('pharmacy')
                    ->relationship('pharmacy', 'name')
                    ->label('Pharmacie')
                    ->searchable()
                    ->preload(),
            ])
            ->actions([
                Tables\Actions\Action::make('update_stock')
                    ->label('Mettre à jour')
                    ->icon('heroicon-m-pencil-square')
                    ->color('primary')
                    ->form([
                        \Filament\Forms\Components\TextInput::make('new_stock')
                            ->label('Nouvelle quantité')
                            ->numeric()
                            ->required()
                            ->minValue(0)
                            ->default(fn (Product $record) => $record->stock_quantity),
                    ])
                    ->action(function (Product $record, array $data): void {
                        $record->update(['stock_quantity' => $data['new_stock']]);
                        
                        \Filament\Notifications\Notification::make()
                            ->title('Stock mis à jour')
                            ->body("Le stock de {$record->name} est maintenant de {$data['new_stock']} unités.")
                            ->success()
                            ->send();
                    }),
                    
                Tables\Actions\Action::make('view')
                    ->label('Voir')
                    ->icon('heroicon-m-eye')
                    ->color('gray')
                    ->url(fn (Product $record): string => route('filament.admin.resources.products.edit', $record)),
            ])
            ->bulkActions([
                Tables\Actions\BulkAction::make('mark_unavailable')
                    ->label('Marquer indisponible')
                    ->icon('heroicon-m-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->action(fn ($records) => $records->each->update(['is_available' => false])),
            ])
            ->emptyStateHeading('Aucune alerte')
            ->emptyStateDescription('Tous les produits ont un stock suffisant et ne sont pas proches de l\'expiration.')
            ->emptyStateIcon('heroicon-o-check-circle')
            ->poll('60s');
    }
}
