<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DutyZoneResource\Pages;
use App\Filament\Resources\DutyZoneResource\RelationManagers;
use App\Models\DutyZone;
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

class DutyZoneResource extends Resource
{
    protected static ?string $model = DutyZone::class;

    protected static ?string $navigationIcon = 'heroicon-o-map';
    
    protected static ?string $navigationLabel = 'Zones de garde';

    protected static ?string $navigationGroup = 'Gestion des gardes';

    protected static ?int $navigationSort = 2;

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('is_active', true)->count() ?: null;
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations de la zone')
                    ->description('Définissez les détails de la zone de garde')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Nom de la zone')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('Ex: Zone Centre Abidjan'),
                        Forms\Components\TextInput::make('city')
                            ->label('Ville')
                            ->maxLength(255)
                            ->placeholder('Ex: Abidjan'),
                        Forms\Components\Textarea::make('description')
                            ->label('Description')
                            ->placeholder('Description détaillée de la zone couverte...')
                            ->columnSpanFull()
                            ->rows(3),
                        Forms\Components\Toggle::make('is_active')
                            ->label('Zone active')
                            ->default(true)
                            ->required()
                            ->helperText('Les zones inactives ne seront pas visibles dans l\'application'),
                    ])->columns(2),
                    
                Forms\Components\Section::make('Coordonnées géographiques (optionnel)')
                    ->description('Pour centrer la carte sur cette zone')
                    ->schema([
                        Forms\Components\TextInput::make('latitude')
                            ->label('Latitude')
                            ->numeric()
                            ->placeholder('Ex: 5.3600'),
                        Forms\Components\TextInput::make('longitude')
                            ->label('Longitude')
                            ->numeric()
                            ->placeholder('Ex: -4.0083'),
                        Forms\Components\TextInput::make('radius')
                            ->label('Rayon (km)')
                            ->numeric()
                            ->default(10)
                            ->placeholder('Ex: 10'),
                    ])->columns(3)->collapsible(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Zone')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),
                Tables\Columns\TextColumn::make('city')
                    ->label('Ville')
                    ->searchable()
                    ->badge()
                    ->color('info'),
                Tables\Columns\TextColumn::make('pharmacies_count')
                    ->label('Pharmacies')
                    ->counts('pharmacies')
                    ->badge()
                    ->color('success'),
                Tables\Columns\TextColumn::make('active_on_calls_count')
                    ->label('Gardes actives')
                    ->getStateUsing(function (DutyZone $record): int {
                        return $record->onCalls()
                            ->where('is_active', true)
                            ->where('start_at', '<=', now())
                            ->where('end_at', '>=', now())
                            ->count();
                    })
                    ->badge()
                    ->color(fn (int $state): string => $state > 0 ? 'success' : 'gray'),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Active')
                    ->boolean(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créée le')
                    ->dateTime('d/m/Y')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Statut'),
                Tables\Filters\SelectFilter::make('city')
                    ->label('Ville')
                    ->options(fn () => DutyZone::distinct()->pluck('city', 'city')->filter()),
            ])
            ->actions([
                Tables\Actions\ActionGroup::make([
                    Tables\Actions\ViewAction::make(),
                    Tables\Actions\EditAction::make(),
                    Tables\Actions\Action::make('view_pharmacies')
                        ->label('Voir les pharmacies')
                        ->icon('heroicon-o-building-storefront')
                        ->color('info')
                        ->url(fn (DutyZone $record): string => 
                            PharmacyResource::getUrl('index', ['tableFilters[duty_zone_id][value]' => $record->id])
                        ),
                    Tables\Actions\Action::make('create_on_call')
                        ->label('Créer une garde')
                        ->icon('heroicon-o-plus-circle')
                        ->color('success')
                        ->url(fn (DutyZone $record): string => 
                            PharmacyOnCallResource::getUrl('create', ['duty_zone_id' => $record->id])
                        ),
                    Tables\Actions\Action::make('toggle_active')
                        ->label(fn (DutyZone $record): string => $record->is_active ? 'Désactiver' : 'Activer')
                        ->icon(fn (DutyZone $record): string => $record->is_active ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle')
                        ->color(fn (DutyZone $record): string => $record->is_active ? 'danger' : 'success')
                        ->requiresConfirmation()
                        ->action(function (DutyZone $record): void {
                            $record->update(['is_active' => !$record->is_active]);
                            Notification::make()
                                ->title($record->is_active ? 'Zone activée' : 'Zone désactivée')
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
            RelationManagers\PharmaciesRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListDutyZones::route('/'),
            'create' => Pages\CreateDutyZone::route('/create'),
            'edit' => Pages\EditDutyZone::route('/{record}/edit'),
        ];
    }
}
