<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CommissionResource\Pages;
use App\Filament\Resources\CommissionResource\RelationManagers;
use App\Models\Commission;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class CommissionResource extends Resource
{
    protected static ?string $model = Commission::class;

    protected static ?string $navigationIcon = 'heroicon-o-banknotes';
    
    protected static ?string $navigationLabel = 'Commissions';
    
    protected static ?string $modelLabel = 'Commission';
    
    protected static ?string $pluralModelLabel = 'Commissions';
    
    protected static ?string $navigationGroup = 'Finance';

    public static function canCreate(): bool
    {
        return false; 
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Détails de la Commission')
                    ->schema([
                        Forms\Components\Select::make('order_id')
                            ->label('Commande')
                            ->relationship('order', 'reference')
                            ->disabled(),
                        Forms\Components\TextInput::make('total_amount')
                            ->label('Montant Total')
                            ->suffix('FCFA')
                            ->disabled(),
                        Forms\Components\DateTimePicker::make('calculated_at')
                            ->label('Calculé le')
                            ->disabled(),
                    ])->columns(3),
                    
                Forms\Components\Repeater::make('lines')
                    ->relationship()
                    ->schema([
                        Forms\Components\TextInput::make('actor_type')
                            ->label('Bénéficiaire')
                            ->formatStateUsing(fn ($state) => match ($state) {
                                'platform' => 'Plateforme',
                                'App\Models\Pharmacy' => 'Pharmacie',
                                'App\Models\Courier' => 'Livreur',
                                default => $state,
                            })
                            ->disabled(),
                        Forms\Components\TextInput::make('amount')
                            ->label('Montant')
                            ->suffix('FCFA')
                            ->disabled(),
                        Forms\Components\TextInput::make('rate')
                            ->label('Taux')
                            ->formatStateUsing(fn ($state) => ($state * 100) . '%')
                            ->disabled(),
                    ])
                    ->columns(3)
                    ->label('Répartition')
                    ->addable(false)
                    ->deletable(false)
                    ->reorderable(false),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('order.reference')
                    ->label('Commande')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('total_amount')
                    ->label('Total Débité')
                    ->money('XOF')
                    ->sortable(),
                Tables\Columns\TextColumn::make('calculated_at')
                    ->label('Date')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),

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
            'index' => Pages\ListCommissions::route('/'),
            'create' => Pages\CreateCommission::route('/create'),
            'edit' => Pages\EditCommission::route('/{record}/edit'),
        ];
    }
}
