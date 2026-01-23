<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PharmacyResource\Pages;
use App\Filament\Resources\PharmacyResource\RelationManagers;
use App\Models\Pharmacy;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class PharmacyResource extends Resource
{
    protected static ?string $model = Pharmacy::class;

    protected static ?string $navigationIcon = 'heroicon-o-building-storefront';
    
    protected static ?string $navigationLabel = 'Pharmacies';
    
    protected static ?string $navigationGroup = 'Gestion';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations générales')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Nom de la pharmacie')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('phone')
                            ->label('Téléphone')
                            ->tel()
                            ->required()
                            ->maxLength(20),
                        Forms\Components\TextInput::make('email')
                            ->label('Email')
                            ->email()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('license_number')
                            ->label('Numéro de licence')
                            ->maxLength(100),
                        Forms\Components\FileUpload::make('license_document')
                            ->label('Document de Licence (PDF/Image)')
                            ->directory('pharmacy-licenses')
                            ->acceptedFileTypes(['application/pdf', 'image/*'])
                            ->openable()
                            ->columnSpanFull(),
                        Forms\Components\FileUpload::make('id_card_document')
                            ->label('CNI / Pièce d\'Identité (PDF/Image)')
                            ->directory('pharmacy-licenses')
                            ->acceptedFileTypes(['application/pdf', 'image/*'])
                            ->openable()
                            ->columnSpanFull(),
                        Forms\Components\TextInput::make('owner_name')
                            ->label('Propriétaire')
                            ->maxLength(255),
                    ])->columns(2),
                
                Forms\Components\Section::make('Adresse')
                    ->schema([
                        Forms\Components\Textarea::make('address')
                            ->label('Adresse complète')
                            ->required()
                            ->rows(3)
                            ->columnSpanFull(),
                        Forms\Components\TextInput::make('city')
                            ->label('Ville')
                            ->required()
                            ->maxLength(100),
                        Forms\Components\TextInput::make('region')
                            ->label('Région')
                            ->maxLength(100),
                        Forms\Components\Select::make('duty_zone_id')
                            ->label('Zone de Garde')
                            ->relationship('dutyZone', 'name')
                            ->searchable()
                            ->preload(),
                        Forms\Components\TextInput::make('latitude')
                            ->label('Latitude')
                            ->numeric()
                            ->step(0.000001),
                        Forms\Components\TextInput::make('longitude')
                            ->label('Longitude')
                            ->numeric()
                            ->step(0.000001),
                    ])->columns(2),
                
                Forms\Components\Section::make('Commissions')
                    ->schema([
                        Forms\Components\TextInput::make('commission_rate_platform')
                            ->label('Taux plateforme (%)')
                            ->required()
                            ->numeric()
                            ->default(10)
                            ->suffix('%')
                            ->helperText('Par défaut: 10%'),
                        Forms\Components\TextInput::make('commission_rate_pharmacy')
                            ->label('Taux pharmacie (%)')
                            ->required()
                            ->numeric()
                            ->default(85)
                            ->suffix('%')
                            ->helperText('Par défaut: 85%'),
                        Forms\Components\TextInput::make('commission_rate_courier')
                            ->label('Taux livreur (%)')
                            ->required()
                            ->numeric()
                            ->default(5)
                            ->suffix('%')
                            ->helperText('Par défaut: 5%'),
                    ])->columns(3),
                
                Forms\Components\Section::make('Statut')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('Statut')
                            ->required()
                            ->options([
                                'pending' => 'En attente',
                                'approved' => 'Approuvée',
                                'rejected' => 'Rejetée',
                                'suspended' => 'Suspendue',
                            ])
                            ->default('pending')
                            ->reactive(),
                        Forms\Components\Textarea::make('rejection_reason')
                            ->label('Raison du rejet')
                            ->rows(3)
                            ->visible(fn ($get) => $get('status') === 'rejected')
                            ->columnSpanFull(),
                        Forms\Components\DateTimePicker::make('approved_at')
                            ->label('Date d\'approbation')
                            ->disabled(),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('phone')
                    ->label('Téléphone')
                    ->searchable(),
                Tables\Columns\TextColumn::make('email')
                    ->label('Email')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('city')
                    ->label('Ville')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('dutyZone.name')
                    ->label('Zone de Garde')
                    ->sortable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('license_number')
                    ->label('Licence')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'approved' => 'success',
                        'rejected' => 'danger',
                        'suspended' => 'gray',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'En attente',
                        'approved' => 'Approuvée',
                        'rejected' => 'Rejetée',
                        'suspended' => 'Suspendue',
                        default => $state,
                    })
                    ->sortable(),
                Tables\Columns\TextColumn::make('commission_rate_pharmacy')
                    ->label('Commission (%)')
                    ->formatStateUsing(fn ($state) => ($state * 100) . '%')
                    ->sortable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('approved_at')
                    ->label('Approuvée le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créée le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Statut')
                    ->options([
                        'pending' => 'En attente',
                        'approved' => 'Approuvée',
                        'rejected' => 'Rejetée',
                        'suspended' => 'Suspendue',
                    ]),
                Tables\Filters\SelectFilter::make('city')
                    ->label('Ville')
                    ->options(fn () => Pharmacy::query()->whereNotNull('city')->distinct()->pluck('city', 'city')->toArray()),
                Tables\Filters\SelectFilter::make('duty_zone_id')
                    ->label('Zone de Garde')
                    ->relationship('dutyZone', 'name'),
                Tables\Filters\TrashedFilter::make(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('approve')
                    ->label('Approuver')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->visible(fn (Pharmacy $record) => $record->status === 'pending')
                    ->action(function (Pharmacy $record) {
                        $record->update([
                            'status' => 'approved',
                            'approved_at' => now(),
                            'rejection_reason' => null,
                        ]);
                        
                        Notification::make()
                            ->success()
                            ->title('Pharmacie approuvée')
                            ->body("La pharmacie {$record->name} a été approuvée avec succès.")
                            ->send();
                    }),
                Tables\Actions\Action::make('reject')
                    ->label('Rejeter')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->visible(fn (Pharmacy $record) => $record->status === 'pending')
                    ->form([
                        Forms\Components\Textarea::make('rejection_reason')
                            ->label('Raison du rejet')
                            ->required()
                            ->rows(3),
                    ])
                    ->action(function (Pharmacy $record, array $data) {
                        $record->update([
                            'status' => 'rejected',
                            'rejection_reason' => $data['rejection_reason'],
                            'approved_at' => null,
                        ]);
                        
                        Notification::make()
                            ->warning()
                            ->title('Pharmacie rejetée')
                            ->body("La pharmacie {$record->name} a été rejetée.")
                            ->send();
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\RestoreBulkAction::make(),
                    Tables\Actions\ForceDeleteBulkAction::make(),
                ]),
                Tables\Actions\BulkAction::make('approveSelected')
                    ->label('Approuver sélection')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->action(function (\Illuminate\Database\Eloquent\Collection $records) {
                        $count = 0;
                        foreach ($records as $record) {
                            if ($record->status === 'pending') {
                                $record->update([
                                    'status' => 'approved',
                                    'approved_at' => now(),
                                    'rejection_reason' => null,
                                ]);
                                $count++;
                            }
                        }
                        Notification::make()
                            ->success()
                            ->title('Pharmacies approuvées')
                            ->body("{$count} pharmacie(s) ont été approuvée(s).")
                            ->send();
                    })
                    ->deselectRecordsAfterCompletion(),
                Tables\Actions\BulkAction::make('exportCsv')
                    ->label('Exporter CSV')
                    ->icon('heroicon-o-arrow-down-tray')
                    ->action(function (\Illuminate\Database\Eloquent\Collection $records) {
                        $csvData = "ID,Nom,Email,Téléphone,Ville,Statut,Date création\n";
                        foreach ($records as $record) {
                            $csvData .= "{$record->id},{$record->name},{$record->email},{$record->phone},{$record->city},{$record->status},{$record->created_at}\n";
                        }
                        
                        return response()->streamDownload(function () use ($csvData) {
                            echo $csvData;
                        }, 'pharmacies_export_' . now()->format('Ymd_His') . '.csv');
                    }),
            ])->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\ProductsRelationManager::class,
            RelationManagers\UsersRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPharmacies::route('/'),
            'create' => Pages\CreatePharmacy::route('/create'),
            'edit' => Pages\EditPharmacy::route('/{record}/edit'),
        ];
    }
}

