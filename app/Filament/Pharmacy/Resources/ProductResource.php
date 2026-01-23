<?php

namespace App\Filament\Pharmacy\Resources;

use App\Filament\Pharmacy\Resources\ProductResource\Pages;
use App\Models\Product;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class ProductResource extends Resource
{
    protected static ?string $model = Product::class;

    protected static ?string $navigationIcon = 'heroicon-o-cube';
    
    protected static ?string $navigationLabel = 'Produits';

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->whereHas('pharmacy', function ($query) {
            $query->whereIn('id', Auth::user()->pharmacies->pluck('id'));
        });
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations de base')
                    ->schema([
                        Forms\Components\Select::make('pharmacy_id')
                            ->label('Pharmacie')
                            ->options(fn () => Auth::user()->pharmacies->pluck('name', 'id'))
                            ->required()
                            ->default(fn () => Auth::user()->pharmacies->first()?->id),
                        Forms\Components\TextInput::make('name')
                            ->label('Nom du produit')
                            ->required()
                            ->maxLength(255)
                            ->live(onBlur: true)
                            ->afterStateUpdated(fn (string $operation, $state, Forms\Set $set) => 
                                $operation === 'create' ? $set('slug', Str::slug($state)) : null
                            ),
                        Forms\Components\TextInput::make('slug')
                            ->required()
                            ->maxLength(255)
                            ->unique(ignoreRecord: true),
                        Forms\Components\Textarea::make('description')
                            ->label('Description')
                            ->rows(3)
                            ->columnSpanFull(),
                        Forms\Components\TextInput::make('category')
                            ->label('Catégorie')
                            ->datalist([
                                'Médicaments',
                                'Compléments Alimentaires',
                                'Matériel Médical',
                                'Hygiène & Beauté',
                                'Bébé & Maman',
                                'Premiers Soins',
                            ]),
                        Forms\Components\TextInput::make('active_ingredient')
                            ->label('DCI (Dénomination Commune Internationale)')
                            ->maxLength(255),
                        Forms\Components\DatePicker::make('expiry_date')
                            ->label('Date d\'expiration'),
                        Forms\Components\Select::make('is_available')
                            ->label('Statut')
                            ->options([
                                1 => 'En stock',
                                0 => 'Désactivé',
                            ])
                            ->required()
                            ->default(1),
                        Forms\Components\Select::make('delivery_option')
                            ->label('Options de livraison')
                            ->options([
                                'all' => 'Livraison & Retrait',
                                'pickup_only' => 'Retrait uniquement',
                            ])
                            ->required()
                            ->default('all'),
                    ])->columns(2),

                Forms\Components\Section::make('Prix et Stock')
                    ->schema([
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
                        Forms\Components\TextInput::make('low_stock_threshold')
                            ->label('Seuil alerte stock')
                            ->numeric()
                            ->default(10),
                    ])->columns(3),
                
                Forms\Components\Section::make('Image')
                    ->schema([
                        Forms\Components\FileUpload::make('image')
                            ->label('Image du produit')
                            ->image()
                            ->directory('products'),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label('Image'),
                Tables\Columns\TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('category')
                    ->label('Catégorie')
                    ->searchable(),
                Tables\Columns\TextColumn::make('price')
                    ->label('Prix')
                    ->money('XOF')
                    ->sortable(),
                Tables\Columns\TextColumn::make('stock_quantity')
                    ->label('Stock')
                    ->numeric()
                    ->sortable()
                    ->color(fn (Product $record) => $record->stock_quantity <= $record->low_stock_threshold ? 'danger' : 'success'),
                Tables\Columns\IconColumn::make('is_available')
                    ->label('Actif')
                    ->boolean(),
                Tables\Columns\TextColumn::make('delivery_option')
                    ->label('Mode')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'all' => 'Livraison + Retrait',
                        'pickup_only' => 'Retrait seul',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'all' => 'success',
                        'pickup_only' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('expiry_date')
                    ->label('Expiration')
                    ->date('d/m/Y')
                    ->sortable()
                    ->color(fn (Product $record) => $record->expiry_date && $record->expiry_date->isPast() ? 'danger' : ($record->expiry_date && $record->expiry_date->diffInDays(now()) < 30 ? 'warning' : 'success')),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
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
            'index' => Pages\ListProducts::route('/'),
            'create' => Pages\CreateProduct::route('/create'),
            'edit' => Pages\EditProduct::route('/{record}/edit'),
        ];
    }
}
