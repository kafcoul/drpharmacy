<?php

namespace App\Filament\Support\Resources;

use App\Filament\Support\Resources\DeliveryResource\Pages;
use App\Filament\Support\Resources\DeliveryResource\RelationManagers;
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

    protected static ?string $navigationIcon = 'heroicon-o-map-pin';
    
    protected static ?string $navigationLabel = 'Livraisons';
    
    protected static ?string $navigationGroup = 'Support';
    
    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('order_id')
                    ->relationship('order', 'id')
                    ->required(),
                Forms\Components\Select::make('courier_id')
                    ->relationship('courier', 'name'),
                Forms\Components\TextInput::make('status')
                    ->required(),
                Forms\Components\TextInput::make('pickup_latitude')
                    ->numeric(),
                Forms\Components\TextInput::make('pickup_longitude')
                    ->numeric(),
                Forms\Components\TextInput::make('dropoff_latitude')
                    ->numeric(),
                Forms\Components\TextInput::make('dropoff_longitude')
                    ->numeric(),
                Forms\Components\TextInput::make('estimated_distance')
                    ->numeric(),
                Forms\Components\TextInput::make('estimated_duration')
                    ->numeric(),
                Forms\Components\DateTimePicker::make('assigned_at'),
                Forms\Components\DateTimePicker::make('accepted_at'),
                Forms\Components\DateTimePicker::make('picked_up_at'),
                Forms\Components\DateTimePicker::make('delivered_at'),
                Forms\Components\Textarea::make('delivery_notes')
                    ->columnSpanFull(),
                Forms\Components\FileUpload::make('delivery_proof_image')
                    ->image(),
                Forms\Components\Textarea::make('failure_reason')
                    ->columnSpanFull(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('order.id')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('courier.name')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->searchable(),
                Tables\Columns\TextColumn::make('pickup_latitude')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('pickup_longitude')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('dropoff_latitude')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('dropoff_longitude')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('estimated_distance')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('estimated_duration')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('assigned_at')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\TextColumn::make('accepted_at')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\TextColumn::make('picked_up_at')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\TextColumn::make('delivered_at')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\ImageColumn::make('delivery_proof_image'),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
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
