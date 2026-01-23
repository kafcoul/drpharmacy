<?php

namespace App\Filament\Resources\PharmacyResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class ProductsRelationManager extends RelationManager
{
    protected static string $relationship = 'products';

    protected static ?string $title = 'Produits de la pharmacie';

    protected static ?string $recordTitleAttribute = 'name';

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('Nom du produit')
                    ->required()
                    ->maxLength(255),
                Forms\Components\Textarea::make('description')
                    ->label('Description')
                    ->rows(3)
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('category')
                    ->label('Catégorie')
                    ->required(),
                Forms\Components\TextInput::make('price')
                    ->label('Prix')
                    ->required()
                    ->numeric()
                    ->prefix('FCFA'),
                Forms\Components\TextInput::make('stock_quantity')
                    ->label('Stock')
                    ->required()
                    ->numeric()
                    ->default(0),
                Forms\Components\Toggle::make('requires_prescription')
                    ->label('Ordonnance requise')
                    ->default(false),
                Forms\Components\Toggle::make('is_available')
                    ->label('Disponible')
                    ->default(true),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('category')
                    ->label('Catégorie')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('price')
                    ->label('Prix')
                    ->money('XOF')
                    ->sortable(),
                Tables\Columns\TextColumn::make('stock_quantity')
                    ->label('Stock')
                    ->sortable()
                    ->color(fn ($state) => $state <= 5 ? ($state == 0 ? 'danger' : 'warning') : 'success'),
                Tables\Columns\IconColumn::make('requires_prescription')
                    ->label('Ordonnance')
                    ->boolean(),
                Tables\Columns\IconColumn::make('is_available')
                    ->label('Disponible')
                    ->boolean(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('category')
                    ->label('Catégorie')
                    ->options(fn () => \App\Models\Product::query()
                        ->whereNotNull('category')
                        ->distinct()
                        ->pluck('category', 'category')
                        ->toArray()
                    ),
                Tables\Filters\TernaryFilter::make('is_available')
                    ->label('Disponibilité'),
                Tables\Filters\TernaryFilter::make('requires_prescription')
                    ->label('Ordonnance requise'),
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make(),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('updateStock')
                    ->label('Modifier stock')
                    ->icon('heroicon-o-cube')
                    ->form([
                        Forms\Components\TextInput::make('stock_quantity')
                            ->label('Nouvelle quantité')
                            ->required()
                            ->numeric()
                            ->minValue(0),
                    ])
                    ->action(fn ($record, array $data) => $record->update(['stock_quantity' => $data['stock_quantity']])),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('name');
    }
}
