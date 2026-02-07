<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DeliveryResource\Pages;
use App\Filament\Resources\DeliveryResource\RelationManagers;
use App\Models\Delivery;
use App\Models\Courier;
use App\Services\AutoAssignmentService;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Illuminate\Database\Eloquent\Collection;

class DeliveryResource extends Resource
{
    protected static ?string $model = Delivery::class;

    protected static ?string $navigationIcon = 'heroicon-o-map';
    
    protected static ?string $navigationLabel = 'Livraisons';
    
    protected static ?string $modelLabel = 'Livraison';
    
    protected static ?string $pluralModelLabel = 'Livraisons';
    
    protected static ?string $navigationGroup = 'Logistique';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations de la course')
                    ->schema([
                        Forms\Components\Select::make('order_id')
                            ->relationship('order', 'reference')
                            ->label('Commande')
                            ->required()
                            ->disabled(),
                        Forms\Components\Select::make('courier_id')
                            ->relationship('courier', 'name')
                            ->label('Livreur')
                            ->searchable()
                            ->preload(),
                        Forms\Components\Select::make('status')
                            ->options([
                                'pending' => 'En attente',
                                'assigned' => 'Assignée',
                                'accepted' => 'Acceptée',
                                'picked_up' => 'Récupérée',
                                'in_transit' => 'En transit',
                                'delivered' => 'Livrée',
                                'cancelled' => 'Annulée',
                                'failed' => 'Échouée',
                            ])
                            ->required(),
                    ])->columns(3),
                
                Forms\Components\Section::make('Détails logistiques')
                    ->schema([
                        Forms\Components\TextInput::make('pickup_latitude')->numeric(),
                        Forms\Components\TextInput::make('pickup_longitude')->numeric(),
                        Forms\Components\TextInput::make('dropoff_latitude')->numeric(),
                        Forms\Components\TextInput::make('dropoff_longitude')->numeric(),
                    ])->columns(4)->collapsed(),

                Forms\Components\Section::make('Chronologie')
                    ->schema([
                        Forms\Components\DateTimePicker::make('assigned_at')->label('Assignée le'),
                        Forms\Components\DateTimePicker::make('accepted_at')->label('Acceptée le'),
                        Forms\Components\DateTimePicker::make('picked_up_at')->label('Récupérée le'),
                        Forms\Components\DateTimePicker::make('delivered_at')->label('Livrée le'),
                    ])->columns(2),

                Forms\Components\FileUpload::make('delivery_proof_image')
                    ->label('Preuve de livraison')
                    ->image()
                    ->columnSpanFull(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(fn (Builder $query) => $query->with(['order.customer', 'order.pharmacy', 'courier']))
            ->columns([
                Tables\Columns\TextColumn::make('order.reference')
                    ->label('Réf. Commande')
                    ->searchable()
                    ->sortable()
                    ->copyable(),
                
                Tables\Columns\TextColumn::make('order.customer.name')
                    ->label('Client')
                    ->searchable()
                    ->placeholder('-'),
                
                Tables\Columns\TextColumn::make('order.pharmacy.name')
                    ->label('Pharmacie')
                    ->searchable()
                    ->toggleable(),
                
                Tables\Columns\TextColumn::make('courier.name')
                    ->label('Livreur')
                    ->searchable()
                    ->placeholder('⏳ Non assigné')
                    ->badge()
                    ->color(fn (?string $state): string => $state ? 'success' : 'warning'),
                
                Tables\Columns\TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => '⏳ En attente',
                        'assigned' => '👤 Assignée',
                        'accepted' => '✅ Acceptée',
                        'picked_up' => '📦 Récupérée',
                        'in_transit' => '🚚 En transit',
                        'delivered' => '✅ Livrée',
                        'cancelled' => '❌ Annulée',
                        'failed' => '⚠️ Échouée',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'gray',
                        'assigned' => 'info',
                        'accepted' => 'primary',
                        'picked_up', 'in_transit' => 'warning',
                        'delivered' => 'success',
                        default => 'danger',
                    }),
                
                Tables\Columns\TextColumn::make('order.total_amount')
                    ->label('Montant')
                    ->money('XOF')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créée')
                    ->dateTime('d/m H:i')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('delivered_at')
                    ->dateTime('d/m H:i')
                    ->label('Livrée le')
                    ->sortable()
                    ->placeholder('-'),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Statut')
                    ->multiple()
                    ->options([
                        'pending' => '⏳ En attente',
                        'assigned' => '👤 Assignée',
                        'accepted' => '✅ Acceptée',
                        'picked_up' => '📦 Récupérée',
                        'in_transit' => '🚚 En transit',
                        'delivered' => '✅ Livrée',
                        'cancelled' => '❌ Annulée',
                    ]),
                Tables\Filters\Filter::make('non_assignees')
                    ->label('Non assignées uniquement')
                    ->query(fn (Builder $query): Builder => $query->whereNull('courier_id')),
                Tables\Filters\Filter::make('today')
                    ->label('Aujourd\'hui')
                    ->query(fn (Builder $query): Builder => $query->whereDate('created_at', today())),
            ])
            ->actions([
                // === ACTION: ASSIGNATION AUTOMATIQUE ===
                Tables\Actions\Action::make('auto_assign')
                    ->label('Auto-assigner')
                    ->icon('heroicon-o-bolt')
                    ->color('success')
                    ->visible(fn (Delivery $record): bool => $record->status === 'pending' || $record->courier_id === null)
                    ->requiresConfirmation()
                    ->modalHeading('Assignation automatique')
                    ->modalDescription('Le système va trouver le meilleur livreur disponible basé sur: proximité, note, expérience et activité récente.')
                    ->modalSubmitActionLabel('Lancer l\'assignation')
                    ->action(function (Delivery $record): void {
                        $service = app(AutoAssignmentService::class);
                        $courier = $service->assignDelivery($record);
                        
                        if ($courier) {
                            Notification::make()
                                ->title('Livreur assigné automatiquement!')
                                ->body("🎯 {$courier->name} a été sélectionné (Score: {$courier->assignment_score})")
                                ->success()
                                ->send();
                        } else {
                            Notification::make()
                                ->title('Aucun livreur disponible')
                                ->body('Aucun livreur disponible à proximité. Réessayez plus tard ou assignez manuellement.')
                                ->warning()
                                ->send();
                        }
                    }),

                // === ACTION: RÉASSIGNATION AUTOMATIQUE ===
                Tables\Actions\Action::make('reassign')
                    ->label('Réassigner')
                    ->icon('heroicon-o-arrow-path')
                    ->color('warning')
                    ->visible(fn (Delivery $record): bool => 
                        $record->courier_id !== null && 
                        in_array($record->status, ['assigned', 'accepted'])
                    )
                    ->form([
                        Forms\Components\Textarea::make('reason')
                            ->label('Raison de la réassignation')
                            ->placeholder('Ex: Livreur indisponible, problème véhicule...')
                            ->rows(2),
                    ])
                    ->action(function (Delivery $record, array $data): void {
                        $service = app(AutoAssignmentService::class);
                        $oldCourier = $record->courier?->name ?? 'N/A';
                        $courier = $service->reassignDelivery($record, $data['reason'] ?? null);
                        
                        if ($courier) {
                            Notification::make()
                                ->title('Livraison réassignée!')
                                ->body("🔄 {$oldCourier} → {$courier->name}")
                                ->success()
                                ->send();
                        } else {
                            Notification::make()
                                ->title('Aucun autre livreur disponible')
                                ->body('La livraison reste en attente d\'un nouveau livreur.')
                                ->warning()
                                ->send();
                        }
                    })
                    ->modalHeading('Réassigner la livraison')
                    ->modalSubmitActionLabel('Réassigner')
                    ->modalWidth('md'),

                // === ACTION MANUELLE: ASSIGNER UN LIVREUR ===
                Tables\Actions\Action::make('assigner')
                    ->label('Assigner manuellement')
                    ->icon('heroicon-o-user-plus')
                    ->color('gray')
                    ->visible(fn (Delivery $record): bool => $record->status === 'pending' || $record->courier_id === null)
                    ->form([
                        Forms\Components\Select::make('courier_id')
                            ->label('Sélectionner un livreur')
                            ->options(function () {
                                return Courier::where('status', 'available')
                                    ->get()
                                    ->mapWithKeys(fn ($courier) => [
                                        $courier->id => "🟢 {$courier->name} ({$courier->completed_deliveries} livraisons)"
                                    ]);
                            })
                            ->required()
                            ->searchable()
                            ->helperText('Seuls les livreurs disponibles sont affichés'),
                    ])
                    ->action(function (Delivery $record, array $data): void {
                        $record->update([
                            'courier_id' => $data['courier_id'],
                            'status' => 'assigned',
                            'assigned_at' => now(),
                        ]);
                        
                        // Mettre le coursier en "occupé"
                        Courier::find($data['courier_id'])?->update(['status' => 'busy']);
                        
                        Notification::make()
                            ->title('Livreur assigné avec succès!')
                            ->success()
                            ->send();
                    })
                    ->modalHeading('Assigner un livreur')
                    ->modalSubmitActionLabel('Assigner')
                    ->modalWidth('md'),

                // === ACTION RAPIDE: MARQUER RÉCUPÉRÉE ===
                Tables\Actions\Action::make('picked_up')
                    ->label('Récupérée')
                    ->icon('heroicon-o-archive-box')
                    ->color('warning')
                    ->visible(fn (Delivery $record): bool => in_array($record->status, ['assigned', 'accepted']))
                    ->requiresConfirmation()
                    ->modalHeading('Confirmer la récupération')
                    ->modalDescription('Le livreur a récupéré la commande à la pharmacie?')
                    ->action(function (Delivery $record): void {
                        $record->update([
                            'status' => 'picked_up',
                            'picked_up_at' => now(),
                        ]);
                        
                        Notification::make()
                            ->title('Commande marquée comme récupérée')
                            ->success()
                            ->send();
                    }),

                // === ACTION RAPIDE: MARQUER EN TRANSIT ===
                Tables\Actions\Action::make('in_transit')
                    ->label('En route')
                    ->icon('heroicon-o-truck')
                    ->color('warning')
                    ->visible(fn (Delivery $record): bool => $record->status === 'picked_up')
                    ->requiresConfirmation()
                    ->modalHeading('Démarrer la livraison')
                    ->modalDescription('Le livreur est en route vers le client?')
                    ->action(function (Delivery $record): void {
                        $record->update(['status' => 'in_transit']);
                        
                        Notification::make()
                            ->title('Livraison en cours')
                            ->success()
                            ->send();
                    }),

                // === ACTION RAPIDE: MARQUER LIVRÉE ===
                Tables\Actions\Action::make('delivered')
                    ->label('Livrée')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn (Delivery $record): bool => in_array($record->status, ['picked_up', 'in_transit']))
                    ->requiresConfirmation()
                    ->modalHeading('Confirmer la livraison')
                    ->modalDescription('La commande a été livrée au client?')
                    ->action(function (Delivery $record): void {
                        $record->update([
                            'status' => 'delivered',
                            'delivered_at' => now(),
                        ]);
                        
                        // Remettre le coursier disponible
                        $record->courier?->update(['status' => 'available']);
                        
                        // Mettre à jour la commande
                        $record->order?->update([
                            'status' => 'delivered',
                            'delivered_at' => now(),
                        ]);
                        
                        Notification::make()
                            ->title('Livraison confirmée! 🎉')
                            ->success()
                            ->send();
                    }),

                // === ACTION RAPIDE: ANNULER ===
                Tables\Actions\Action::make('cancel')
                    ->label('Annuler')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->visible(fn (Delivery $record): bool => !in_array($record->status, ['delivered', 'cancelled']))
                    ->requiresConfirmation()
                    ->modalHeading('Annuler la livraison')
                    ->modalDescription('Êtes-vous sûr de vouloir annuler cette livraison?')
                    ->form([
                        Forms\Components\Textarea::make('cancellation_reason')
                            ->label('Raison de l\'annulation')
                            ->required(),
                    ])
                    ->action(function (Delivery $record, array $data): void {
                        $record->update([
                            'status' => 'cancelled',
                            'notes' => $data['cancellation_reason'],
                        ]);
                        
                        // Remettre le coursier disponible
                        $record->courier?->update(['status' => 'available']);
                        
                        Notification::make()
                            ->title('Livraison annulée')
                            ->warning()
                            ->send();
                    }),

                Tables\Actions\ActionGroup::make([
                    Tables\Actions\ViewAction::make(),
                    Tables\Actions\EditAction::make(),
                ])->icon('heroicon-o-ellipsis-vertical'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    // === BULK ACTION: AUTO-ASSIGNATION EN MASSE ===
                    Tables\Actions\BulkAction::make('bulk_auto_assign')
                        ->label('Auto-assigner tout')
                        ->icon('heroicon-o-bolt')
                        ->color('success')
                        ->requiresConfirmation()
                        ->modalHeading('Assignation automatique en masse')
                        ->modalDescription('Le système va assigner automatiquement le meilleur livreur disponible pour chaque livraison sélectionnée.')
                        ->action(function (Collection $records): void {
                            $service = app(AutoAssignmentService::class);
                            $assigned = 0;
                            $failed = 0;
                            
                            foreach ($records as $record) {
                                if ($record->status === 'pending' || $record->courier_id === null) {
                                    $courier = $service->assignDelivery($record);
                                    if ($courier) {
                                        $assigned++;
                                    } else {
                                        $failed++;
                                    }
                                }
                            }
                            
                            if ($assigned > 0) {
                                Notification::make()
                                    ->title("✅ {$assigned} livraison(s) assignée(s) automatiquement")
                                    ->body($failed > 0 ? "⚠️ {$failed} n'ont pas pu être assignées (aucun livreur disponible)" : null)
                                    ->success()
                                    ->send();
                            } else {
                                Notification::make()
                                    ->title('Aucune livraison assignée')
                                    ->body('Aucun livreur disponible pour les livraisons sélectionnées.')
                                    ->warning()
                                    ->send();
                            }
                        })
                        ->deselectRecordsAfterCompletion(),

                    // === BULK ACTION: ASSIGNER MANUELLEMENT EN MASSE ===
                    Tables\Actions\BulkAction::make('bulk_assign')
                        ->label('Assigner à un livreur')
                        ->icon('heroicon-o-user-plus')
                        ->color('primary')
                        ->form([
                            Forms\Components\Select::make('courier_id')
                                ->label('Sélectionner un livreur')
                                ->options(function () {
                                    return Courier::where('status', 'available')
                                        ->get()
                                        ->mapWithKeys(fn ($courier) => [
                                            $courier->id => "🟢 {$courier->name} ({$courier->completed_deliveries} livraisons)"
                                        ]);
                                })
                                ->required()
                                ->searchable(),
                        ])
                        ->action(function (Collection $records, array $data): void {
                            $count = 0;
                            foreach ($records as $record) {
                                if ($record->status === 'pending' || $record->courier_id === null) {
                                    $record->update([
                                        'courier_id' => $data['courier_id'],
                                        'status' => 'assigned',
                                        'assigned_at' => now(),
                                    ]);
                                    $count++;
                                }
                            }
                            
                            Courier::find($data['courier_id'])?->update(['status' => 'busy']);
                            
                            Notification::make()
                                ->title("{$count} livraison(s) assignée(s)")
                                ->success()
                                ->send();
                        })
                        ->deselectRecordsAfterCompletion(),

                    // === BULK ACTION: MARQUER LIVRÉES ===
                    Tables\Actions\BulkAction::make('bulk_delivered')
                        ->label('Marquer comme livrées')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->action(function (Collection $records): void {
                            $count = 0;
                            foreach ($records as $record) {
                                if (in_array($record->status, ['picked_up', 'in_transit'])) {
                                    $record->update([
                                        'status' => 'delivered',
                                        'delivered_at' => now(),
                                    ]);
                                    $record->courier?->update(['status' => 'available']);
                                    $record->order?->update(['status' => 'delivered', 'delivered_at' => now()]);
                                    $count++;
                                }
                            }
                            
                            Notification::make()
                                ->title("{$count} livraison(s) marquée(s) comme livrées")
                                ->success()
                                ->send();
                        })
                        ->deselectRecordsAfterCompletion(),

                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateHeading('Aucune livraison')
            ->emptyStateDescription('Les livraisons apparaîtront ici.')
            ->emptyStateIcon('heroicon-o-truck')
            ->poll('30s'); // Rafraîchir automatiquement toutes les 30 secondes
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getWidgets(): array
    {
        return [
            DeliveryResource\Widgets\DeliveryStatsOverview::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListDeliveries::route('/'),
            'create' => Pages\CreateDelivery::route('/create'),
            'edit' => Pages\EditDelivery::route('/{record}/edit'),
        ];
    }
}
