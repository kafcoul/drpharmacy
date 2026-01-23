<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CourierResource\Pages;
use App\Filament\Resources\CourierResource\RelationManagers;
use App\Models\Courier;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class CourierResource extends Resource
{
    protected static ?string $model = Courier::class;

    protected static ?string $navigationIcon = 'heroicon-o-truck';
    
    protected static ?string $navigationLabel = 'Livreurs';
    
    protected static ?string $navigationGroup = 'Gestion';
    
    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('user_id')
                    ->relationship('user', 'name')
                    ->required()
                    ->createOptionForm([
                        Forms\Components\TextInput::make('name')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('email')
                            ->email()
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('phone')
                            ->tel()
                            ->required()
                            ->maxLength(20),
                        Forms\Components\TextInput::make('password')
                            ->password()
                            ->dehydrateStateUsing(fn ($state) => Hash::make($state))
                            ->required(),
                        Forms\Components\Hidden::make('role')
                            ->default('courier'),
                    ])
                    ->createOptionUsing(function (array $data) {
                        return User::create($data)->id;
                    }),
                Forms\Components\TextInput::make('name')
                    ->required(),
                Forms\Components\TextInput::make('phone')
                    ->tel()
                    ->required(),
                Forms\Components\TextInput::make('vehicle_type'),
                Forms\Components\TextInput::make('vehicle_number'),
                Forms\Components\TextInput::make('license_number'),
                Forms\Components\Section::make('Documents')
                    ->schema([
                        Forms\Components\FileUpload::make('driving_license_document')
                            ->label('Permis de Conduire')
                            ->directory('courier-documents')
                            ->acceptedFileTypes(['application/pdf', 'image/*'])
                            ->openable(),
                        Forms\Components\FileUpload::make('vehicle_registration_document')
                            ->label('Carte Grise')
                            ->directory('courier-documents')
                            ->acceptedFileTypes(['application/pdf', 'image/*'])
                            ->openable(),
                    ])->columns(2),
                Forms\Components\TextInput::make('latitude')
                    ->numeric(),
                Forms\Components\TextInput::make('longitude')
                    ->numeric(),
                Forms\Components\Select::make('status')
                    ->options([
                        'pending_approval' => 'En attente d\'approbation',
                        'available' => 'Disponible',
                        'busy' => 'Occupé',
                        'offline' => 'Hors ligne',
                        'suspended' => 'Suspendu',
                    ])
                    ->required()
                    ->default('pending_approval'),
                Forms\Components\TextInput::make('rating')
                    ->required()
                    ->numeric()
                    ->default(5),
                Forms\Components\TextInput::make('completed_deliveries')
                    ->required()
                    ->numeric()
                    ->default(0),
                Forms\Components\DateTimePicker::make('last_location_update'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('name')
                    ->searchable(),
                Tables\Columns\TextColumn::make('phone')
                    ->searchable(),
                Tables\Columns\TextColumn::make('vehicle_type')
                    ->searchable(),
                Tables\Columns\TextColumn::make('vehicle_number')
                    ->searchable(),
                Tables\Columns\TextColumn::make('license_number')
                    ->searchable(),
                Tables\Columns\TextColumn::make('latitude')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('longitude')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'available' => 'success',
                        'busy' => 'warning',
                        'offline' => 'gray',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'available' => 'Disponible',
                        'busy' => 'Occupé',
                        'offline' => 'Hors ligne',
                        default => $state,
                    })
                    ->searchable(),
                Tables\Columns\TextColumn::make('rating')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('completed_deliveries')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('last_location_update')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('deleted_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Statut')
                    ->options([
                        'available' => 'Disponible',
                        'busy' => 'Occupé',
                        'offline' => 'Hors ligne',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('setAvailable')
                    ->label('Disponible')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn ($record) => $record->status !== 'available')
                    ->action(fn ($record) => $record->update(['status' => 'available'])),
                Tables\Actions\Action::make('setOffline')
                    ->label('Hors ligne')
                    ->icon('heroicon-o-x-circle')
                    ->color('gray')
                    ->visible(fn ($record) => $record->status !== 'offline')
                    ->action(fn ($record) => $record->update(['status' => 'offline'])),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
                Tables\Actions\BulkAction::make('setAllOffline')
                    ->label('Mettre hors ligne')
                    ->icon('heroicon-o-moon')
                    ->color('gray')
                    ->action(fn (\Illuminate\Database\Eloquent\Collection $records) => 
                        $records->each(fn ($record) => $record->update(['status' => 'offline']))
                    )
                    ->deselectRecordsAfterCompletion(),
                Tables\Actions\BulkAction::make('exportCsv')
                    ->label('Exporter CSV')
                    ->icon('heroicon-o-arrow-down-tray')
                    ->action(function (\Illuminate\Database\Eloquent\Collection $records) {
                        $csvData = "ID,Nom,Téléphone,Véhicule,Statut,Livraisons,Note\n";
                        foreach ($records as $record) {
                            $csvData .= "{$record->id},{$record->name},{$record->phone},{$record->vehicle_type},{$record->status},{$record->completed_deliveries},{$record->rating}\n";
                        }
                        
                        return response()->streamDownload(function () use ($csvData) {
                            echo $csvData;
                        }, 'couriers_export_' . now()->format('Ymd_His') . '.csv');
                    }),
            ])->defaultSort('created_at', 'desc');
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
            'index' => Pages\ListCouriers::route('/'),
            'create' => Pages\CreateCourier::route('/create'),
            'edit' => Pages\EditCourier::route('/{record}/edit'),
        ];
    }
}
