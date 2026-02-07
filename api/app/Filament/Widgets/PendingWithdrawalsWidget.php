<?php

namespace App\Filament\Widgets;

use App\Models\WithdrawalRequest;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Filament\Notifications\Notification;

class PendingWithdrawalsWidget extends BaseWidget
{
    protected static ?string $heading = 'Demandes de retrait en attente';
    
    protected static ?int $sort = 7;
    
    protected int | string | array $columnSpan = 'half';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                WithdrawalRequest::query()
                    ->where('status', 'pending')
                    ->orderBy('created_at', 'asc')
                    ->limit(5)
            )
            ->columns([
                Tables\Columns\TextColumn::make('wallet.owner_type')
                    ->label('Type')
                    ->formatStateUsing(fn ($state) => match($state) {
                        'App\\Models\\Pharmacy' => '🏥 Pharmacie',
                        'App\\Models\\Courier' => '🚴 Coursier',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('amount')
                    ->label('Montant')
                    ->money('XOF')
                    ->color('success'),
                Tables\Columns\TextColumn::make('payment_method')
                    ->label('Méthode')
                    ->badge()
                    ->color(fn ($state) => match($state) {
                        'mobile_money' => 'warning',
                        'bank_transfer' => 'info',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Demandé')
                    ->since(),
            ])
            ->actions([
                Tables\Actions\Action::make('approve')
                    ->label('Approuver')
                    ->icon('heroicon-o-check')
                    ->color('success')
                    ->requiresConfirmation()
                    ->action(function ($record) {
                        $record->update(['status' => 'approved']);
                        Notification::make()
                            ->title('Retrait approuvé')
                            ->success()
                            ->send();
                    }),
                Tables\Actions\Action::make('reject')
                    ->label('Refuser')
                    ->icon('heroicon-o-x-mark')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->action(function ($record) {
                        $record->update(['status' => 'rejected']);
                        Notification::make()
                            ->title('Retrait refusé')
                            ->warning()
                            ->send();
                    }),
            ])
            ->paginated(false)
            ->emptyStateHeading('Aucune demande en attente')
            ->emptyStateDescription('Toutes les demandes de retrait ont été traitées.')
            ->emptyStateIcon('heroicon-o-banknotes');
    }
}
