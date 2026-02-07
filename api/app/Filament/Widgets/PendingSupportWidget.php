<?php

namespace App\Filament\Widgets;

use App\Models\SupportTicket;
use App\Models\ProblemReport;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class PendingSupportWidget extends BaseWidget
{
    protected static ?string $heading = 'Tickets support en attente';
    
    protected static ?int $sort = 6;
    
    protected int | string | array $columnSpan = 'half';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                SupportTicket::query()
                    ->where('status', 'open')
                    ->orderBy('created_at', 'desc')
                    ->limit(5)
            )
            ->columns([
                Tables\Columns\TextColumn::make('subject')
                    ->label('Sujet')
                    ->limit(30)
                    ->tooltip(fn ($record) => $record->subject),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Utilisateur')
                    ->limit(15),
                Tables\Columns\BadgeColumn::make('priority')
                    ->label('Priorité')
                    ->colors([
                        'danger' => 'high',
                        'warning' => 'medium',
                        'success' => 'low',
                    ]),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Date')
                    ->since(),
            ])
            ->actions([
                Tables\Actions\Action::make('view')
                    ->label('Voir')
                    ->icon('heroicon-o-eye')
                    ->url(fn ($record) => route('filament.admin.resources.support-tickets.edit', $record)),
            ])
            ->paginated(false)
            ->emptyStateHeading('Aucun ticket en attente')
            ->emptyStateDescription('Tous les tickets ont été traités.')
            ->emptyStateIcon('heroicon-o-check-circle');
    }
}
