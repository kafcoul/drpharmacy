<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PharmacyOnCallResource\Pages;
use App\Filament\Resources\PharmacyOnCallResource\RelationManagers;
use App\Models\PharmacyOnCall;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class PharmacyOnCallResource extends Resource
{
    protected static ?string $model = PharmacyOnCall::class;

    protected static ?string $navigationIcon = 'heroicon-o-calendar';
    
    protected static ?string $navigationLabel = 'Planning des gardes';

    protected static ?string $navigationGroup = 'Gestion des gardes';

    public static function canCreate(): bool
    {
        return false;
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Détails de la garde')
                    ->schema([
                        Forms\Components\Select::make('pharmacy_id')
                            ->label('Pharmacie')
                            ->relationship('pharmacy', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),
                        Forms\Components\Select::make('duty_zone_id')
                            ->label('Zone de garde')
                            ->relationship('dutyZone', 'name')
                            ->searchable()
                            ->preload(),
                        Forms\Components\Select::make('type')
                            ->label('Type de garde')
                            ->options([
                                'night' => 'Garde de nuit',
                                'weekend' => 'Week-end',
                                'holiday' => 'Jour férié',
                                'emergency' => 'Urgence',
                            ])
                            ->required()
                            ->default('night'),
                        Forms\Components\Toggle::make('is_active')
                            ->label('Actif')
                            ->default(true)
                            ->required(),
                        Forms\Components\DateTimePicker::make('start_at')
                            ->label('Début')
                            ->required(),
                        Forms\Components\DateTimePicker::make('end_at')
                            ->label('Fin')
                            ->required()
                            ->after('start_at'),
                    ])->columns(2)
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('pharmacy.name')
                    ->label('Pharmacie')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('dutyZone.name')
                    ->label('Zone')
                    ->sortable()
                    ->badge()
                    ->color('info'),
                Tables\Columns\TextColumn::make('type')
                    ->label('Type')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'night' => 'Nuit',
                        'weekend' => 'Week-end',
                        'holiday' => 'Férié',
                        'emergency' => 'Urgence',
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
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Actif')
                    ->boolean(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('duty_zone_id')
                    ->label('Zone')
                    ->relationship('dutyZone', 'name'),
                Tables\Filters\SelectFilter::make('type')
                    ->label('Type')
                    ->options([
                        'night' => 'Nuit',
                        'weekend' => 'Week-end',
                        'holiday' => 'Férié',
                        'emergency' => 'Urgence',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
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
