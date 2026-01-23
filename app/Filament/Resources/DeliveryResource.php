<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DeliveryResource\Pages;
use App\Filament\Resources\DeliveryResource\RelationManagers;
use App\Models\Delivery;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class DeliveryResource extends Resource
{
    protected static ?string $model = Delivery::class;

    protected static ?string $navigationIcon = 'heroicon-o-map';
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
            ->columns([
                Tables\Columns\TextColumn::make('order.reference')
                    ->label('Réf. Commande')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('courier.name')
                    ->label('Livreur')
                    ->searchable()
                    ->placeholder('Non assigné'),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'gray',
                        'assigned', 'accepted' => 'info',
                        'picked_up', 'in_transit' => 'warning',
                        'delivered' => 'success',
                        default => 'danger',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('delivered_at')
                    ->dateTime()
                    ->label('Livrée le')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                 Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'pending' => 'En attente',
                        'assigned' => 'Assignée',
                        'delivered' => 'Livrée',
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
            'index' => Pages\ListDeliveries::route('/'),
            'create' => Pages\CreateDelivery::route('/create'),
            'edit' => Pages\EditDelivery::route('/{record}/edit'),
        ];
    }
}
