<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PharmacyOnCallResource\Pages;
use App\Filament\Resources\PharmacyOnCallResource\RelationManagers;
use App\Models\PharmacyOnCall;
use App\Models\Pharmacy;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Illuminate\Database\Eloquent\Collection;

class PharmacyOnCallResource extends Resource
{
    protected static ?string $model = PharmacyOnCall::class;

    protected static ?string $navigationIcon = 'heroicon-o-calendar';
    
    protected static ?string $navigationLabel = 'Planning des gardes';

    protected static ?string $navigationGroup = 'Gestion des gardes';

    protected static ?int $navigationSort = 1;

    public static function getNavigationBadge(): ?string
    {
        // Count currently active on-call shifts
        return static::getModel()::where('is_active', true)
            ->where('start_at', '<=', now())
            ->where('end_at', '>=', now())
            ->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'success';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Détails de la garde')
                    ->description('Configurez les détails de la période de garde')
                    ->schema([
                        Forms\Components\Select::make('pharmacy_id')
                            ->label('Pharmacie')
                            ->relationship('pharmacy', 'name', fn (Builder $query) => $query->where('status', 'approved'))
                            ->searchable()
                            ->preload()
                            ->required()
                            ->live()
                            ->afterStateUpdated(function ($state, Forms\Set $set) {
                                if ($state) {
                                    $pharmacy = Pharmacy::find($state);
                                    if ($pharmacy && $pharmacy->duty_zone_id) {
                                        $set('duty_zone_id', $pharmacy->duty_zone_id);
                                    }
                                }
                            }),
                        Forms\Components\Select::make('duty_zone_id')
                            ->label('Zone de garde')
                            ->relationship('dutyZone', 'name')
                            ->searchable()
                            ->preload()
                            ->helperText('Automatiquement rempli depuis la pharmacie si disponible'),
                        Forms\Components\Select::make('type')
                            ->label('Type de garde')
                            ->options([
                                'night' => '🌙 Garde de nuit',
                                'weekend' => '📅 Week-end',
                                'holiday' => '🎉 Jour férié',
                                'emergency' => '🚨 Urgence',
                            ])
                            ->required()
                            ->default('night')
                            ->native(false),
                        Forms\Components\Toggle::make('is_active')
                            ->label('Actif')
                            ->default(true)
                            ->required()
                            ->helperText('Désactivez pour suspendre temporairement cette garde'),
                    ])->columns(2),
                    
                Forms\Components\Section::make('Période de garde')
                    ->description('Définissez les dates et heures de début et fin')
                    ->schema([
                        Forms\Components\DateTimePicker::make('start_at')
                            ->label('Début de la garde')
                            ->required()
                            ->default(now())
                            ->minDate(now()->subDay())
                            ->displayFormat('d/m/Y H:i'),
                        Forms\Components\DateTimePicker::make('end_at')
                            ->label('Fin de la garde')
                            ->required()
                            ->after('start_at')
                            ->displayFormat('d/m/Y H:i')
                            ->helperText('Doit être après la date de début'),
                    ])->columns(2),
                    
                Forms\Components\Section::make('Raccourcis de période')
                    ->description('Utilisez ces boutons pour définir rapidement la période')
                    ->schema([
                        Forms\Components\Actions::make([
                            Forms\Components\Actions\Action::make('tonight')
                                ->label('Ce soir (20h-8h)')
                                ->icon('heroicon-o-moon')
                                ->color('primary')
                                ->action(function (Forms\Set $set) {
                                    $set('start_at', now()->setTime(20, 0));
                                    $set('end_at', now()->addDay()->setTime(8, 0));
                                    $set('type', 'night');
                                }),
                            Forms\Components\Actions\Action::make('this_weekend')
                                ->label('Ce week-end')
                                ->icon('heroicon-o-calendar-days')
                                ->color('success')
                                ->action(function (Forms\Set $set) {
                                    $saturday = now()->next('Saturday')->setTime(8, 0);
                                    $monday = $saturday->copy()->addDays(2)->setTime(8, 0);
                                    $set('start_at', $saturday);
                                    $set('end_at', $monday);
                                    $set('type', 'weekend');
                                }),
                            Forms\Components\Actions\Action::make('24h')
                                ->label('24 heures')
                                ->icon('heroicon-o-clock')
                                ->color('warning')
                                ->action(function (Forms\Set $set) {
                                    $set('start_at', now());
                                    $set('end_at', now()->addDay());
                                }),
                        ])->fullWidth(),
                    ])->collapsible()->collapsed(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('pharmacy.name')
                    ->label('Pharmacie')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),
                Tables\Columns\TextColumn::make('pharmacy.phone')
                    ->label('Téléphone')
                    ->icon('heroicon-o-phone')
                    ->copyable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('pharmacy.address')
                    ->label('Adresse')
                    ->limit(30)
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('dutyZone.name')
                    ->label('Zone')
                    ->sortable()
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
                Tables\Columns\TextColumn::make('start_at')
                    ->label('Début')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('end_at')
                    ->label('Fin')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->label('Statut')
                    ->getStateUsing(function (PharmacyOnCall $record): string {
                        if (!$record->is_active) return 'inactive';
                        if ($record->end_at < now()) return 'expired';
                        if ($record->start_at > now()) return 'scheduled';
                        return 'active';
                    })
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'active' => '✅ En cours',
                        'scheduled' => '📅 Programmée',
                        'expired' => '⏰ Terminée',
                        'inactive' => '❌ Inactive',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'active' => 'success',
                        'scheduled' => 'info',
                        'expired' => 'gray',
                        'inactive' => 'danger',
                        default => 'gray',
                    }),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Actif')
                    ->boolean()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('start_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('duty_zone_id')
                    ->label('Zone')
                    ->relationship('dutyZone', 'name'),
                Tables\Filters\SelectFilter::make('type')
                    ->label('Type')
                    ->options([
                        'night' => '🌙 Nuit',
                        'weekend' => '📅 Week-end',
                        'holiday' => '🎉 Férié',
                        'emergency' => '🚨 Urgence',
                    ]),
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Statut actif'),
                Tables\Filters\Filter::make('current')
                    ->label('Gardes en cours')
                    ->query(fn (Builder $query): Builder => $query
                        ->where('is_active', true)
                        ->where('start_at', '<=', now())
                        ->where('end_at', '>=', now())
                    )
                    ->toggle(),
                Tables\Filters\Filter::make('upcoming')
                    ->label('Gardes à venir')
                    ->query(fn (Builder $query): Builder => $query
                        ->where('is_active', true)
                        ->where('start_at', '>', now())
                    )
                    ->toggle(),
            ])
            ->actions([
                Tables\Actions\ActionGroup::make([
                    Tables\Actions\ViewAction::make(),
                    Tables\Actions\EditAction::make(),
                    Tables\Actions\Action::make('toggle_active')
                        ->label(fn (PharmacyOnCall $record): string => $record->is_active ? 'Désactiver' : 'Activer')
                        ->icon(fn (PharmacyOnCall $record): string => $record->is_active ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle')
                        ->color(fn (PharmacyOnCall $record): string => $record->is_active ? 'danger' : 'success')
                        ->requiresConfirmation()
                        ->action(function (PharmacyOnCall $record): void {
                            $record->update(['is_active' => !$record->is_active]);
                            Notification::make()
                                ->title($record->is_active ? 'Garde activée' : 'Garde désactivée')
                                ->success()
                                ->send();
                        }),
                    Tables\Actions\Action::make('extend')
                        ->label('Prolonger')
                        ->icon('heroicon-o-arrow-right')
                        ->color('warning')
                        ->form([
                            Forms\Components\Select::make('hours')
                                ->label('Prolonger de')
                                ->options([
                                    2 => '2 heures',
                                    4 => '4 heures',
                                    6 => '6 heures',
                                    12 => '12 heures',
                                    24 => '24 heures',
                                ])
                                ->required(),
                        ])
                        ->action(function (PharmacyOnCall $record, array $data): void {
                            $record->update([
                                'end_at' => $record->end_at->addHours($data['hours']),
                            ]);
                            Notification::make()
                                ->title('Garde prolongée')
                                ->body("La garde a été prolongée de {$data['hours']} heures")
                                ->success()
                                ->send();
                        }),
                    Tables\Actions\DeleteAction::make(),
                ]),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('activate')
                        ->label('Activer')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->action(fn (Collection $records) => $records->each->update(['is_active' => true]))
                        ->deselectRecordsAfterCompletion(),
                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Désactiver')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->action(fn (Collection $records) => $records->each->update(['is_active' => false]))
                        ->deselectRecordsAfterCompletion(),
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPharmacyOnCalls::route('/'),
            'create' => Pages\CreatePharmacyOnCall::route('/create'),
            'edit' => Pages\EditPharmacyOnCall::route('/{record}/edit'),
        ];
    }
}
