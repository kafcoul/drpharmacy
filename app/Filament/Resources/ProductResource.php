<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ProductResource\Pages;
use App\Models\Product;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Illuminate\Support\Str;

class ProductResource extends Resource
{
    protected static ?string $model = Product::class;

    protected static ?string $navigationIcon = 'heroicon-o-shopping-bag';

    protected static ?string $navigationGroup = 'Inventory';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Basic Information')
                    ->schema([
                        Forms\Components\Select::make('pharmacy_id')
                            ->relationship('pharmacy', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),
                        Forms\Components\TextInput::make('name')
                            ->required()
                            ->maxLength(255)
                            ->live(onBlur: true)
                            ->afterStateUpdated(fn (string $operation, $state, Forms\Set $set) => 
                                $operation === 'create' ? $set('slug', Str::slug($state)) : null
                            ),
                        Forms\Components\TextInput::make('slug')
                            ->required()
                            ->maxLength(255)
                            ->unique(ignoreRecord: true)
                            ->helperText('Auto-generated from name, can be edited'),
                        Forms\Components\Textarea::make('description')
                            ->rows(3)
                            ->columnSpanFull(),
                        Forms\Components\Select::make('category_id') // Use Select with category_id
                            ->relationship('category', 'name')
                            ->searchable()
                            ->preload()
                             // User explicitly said: "Aucune création de catégorie ne doit être autorisée depuis le formulaire produit"
                            ->required()
                            ->label('Category'),
                        /* Deprecated String Category
                        Forms\Components\TextInput::make('category')
                            ...
                        */
                        Forms\Components\TextInput::make('brand')
                            ->maxLength(255),
                    ])->columns(2),

                Forms\Components\Section::make('Pricing & Stock')
                    ->schema([
                        Forms\Components\TextInput::make('price')
                            ->required()
                            ->numeric()
                            ->prefix('FCFA')
                            ->minValue(0),
                        Forms\Components\TextInput::make('discount_price')
                            ->numeric()
                            ->prefix('FCFA')
                            ->minValue(0)
                            ->lte('price')
                            ->helperText('Leave empty if no discount'),
                        Forms\Components\TextInput::make('stock_quantity')
                            ->required()
                            ->numeric()
                            ->default(0)
                            ->minValue(0),
                        Forms\Components\TextInput::make('low_stock_threshold')
                            ->required()
                            ->numeric()
                            ->default(10)
                            ->minValue(0)
                            ->helperText('Alert when stock reaches this level'),
                        Forms\Components\TextInput::make('sku')
                            ->label('SKU')
                            ->maxLength(255)
                            ->unique(ignoreRecord: true),
                        Forms\Components\TextInput::make('barcode')
                            ->maxLength(255),
                    ])->columns(2),

                Forms\Components\Section::make('Product Details')
                    ->schema([
                        Forms\Components\TextInput::make('unit')
                            ->required()
                            ->default('pièce')
                            ->maxLength(255)
                            ->datalist(['pièce', 'boîte', 'flacon', 'tube', 'sachet', 'ampoule']),
                        Forms\Components\TextInput::make('units_per_pack')
                            ->required()
                            ->numeric()
                            ->default(1)
                            ->minValue(1),
                        Forms\Components\DatePicker::make('expiry_date')
                            ->helperText('Product expiry date'),
                        Forms\Components\TextInput::make('manufacturer')
                            ->maxLength(255),
                        Forms\Components\TextInput::make('active_ingredient')
                            ->maxLength(255)
                            ->helperText('Main active ingredient'),
                        Forms\Components\TagsInput::make('tags')
                            ->placeholder('Add tags')
                            ->helperText('Press enter to add a tag'),
                    ])->columns(2),

                Forms\Components\Section::make('Medical Information')
                    ->schema([
                        Forms\Components\Toggle::make('requires_prescription')
                            ->default(false)
                            ->helperText('Requires medical prescription to purchase'),
                        Forms\Components\Textarea::make('usage_instructions')
                            ->rows(3)
                            ->columnSpanFull(),
                        Forms\Components\Textarea::make('side_effects')
                            ->rows(3)
                            ->columnSpanFull(),
                    ]),

                Forms\Components\Section::make('Images')
                    ->schema([
                        Forms\Components\FileUpload::make('image')
                            ->image()
                            ->maxSize(2048)
                            ->directory('products')
                            ->helperText('Main product image (max 2MB)'),
                        Forms\Components\FileUpload::make('images')
                            ->multiple()
                            ->image()
                            ->maxSize(2048)
                            ->maxFiles(5)
                            ->directory('products')
                            ->helperText('Additional images (max 5 images, 2MB each)')
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('Status & Features')
                    ->schema([
                        Forms\Components\Toggle::make('is_available')
                            ->default(true)
                            ->helperText('Product available for sale'),
                        Forms\Components\Toggle::make('is_featured')
                            ->default(false)
                            ->helperText('Show in featured products'),
                    ])->columns(2),

                Forms\Components\Section::make('Statistics (Read Only)')
                    ->schema([
                        Forms\Components\TextInput::make('views_count')
                            ->numeric()
                            ->default(0)
                            ->disabled(),
                        Forms\Components\TextInput::make('sales_count')
                            ->numeric()
                            ->default(0)
                            ->disabled(),
                        Forms\Components\TextInput::make('average_rating')
                            ->numeric()
                            ->default(0)
                            ->disabled(),
                        Forms\Components\TextInput::make('reviews_count')
                            ->numeric()
                            ->default(0)
                            ->disabled(),
                    ])
                    ->columns(4)
                    ->collapsible()
                    ->collapsed(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->circular(),
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),
                Tables\Columns\TextColumn::make('pharmacy.name')
                    ->searchable()
                    ->sortable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('category')
                    ->searchable()
                    ->badge(),
                Tables\Columns\TextColumn::make('price')
                    ->money('XOF')
                    ->sortable(),
                Tables\Columns\TextColumn::make('discount_price')
                    ->money('XOF')
                    ->sortable()
                    ->toggleable()
                    ->color('success'),
                Tables\Columns\TextColumn::make('stock_quantity')
                    ->numeric()
                    ->sortable()
                    ->color(fn (Product $record): string => match (true) {
                        $record->is_out_of_stock => 'danger',
                        $record->is_low_stock => 'warning',
                        default => 'success',
                    }),
                Tables\Columns\IconColumn::make('requires_prescription')
                    ->boolean()
                    ->toggleable(),
                Tables\Columns\IconColumn::make('is_available')
                    ->boolean()
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_featured')
                    ->boolean()
                    ->sortable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('sales_count')
                    ->numeric()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('views_count')
                    ->numeric()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('expiry_date')
                    ->date()
                    ->sortable()
                    ->color(fn ($state): string => $state && $state < now()->addMonth() ? 'danger' : 'success')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('pharmacy')
                    ->relationship('pharmacy', 'name')
                    ->searchable()
                    ->preload(),
                Tables\Filters\SelectFilter::make('category')
                    ->options(fn () => Product::whereNotNull('category')->distinct()->pluck('category', 'category')->toArray()),
                Tables\Filters\TernaryFilter::make('is_available')
                    ->label('Available')
                    ->placeholder('All products')
                    ->trueLabel('Available only')
                    ->falseLabel('Unavailable only'),
                Tables\Filters\TernaryFilter::make('is_featured')
                    ->label('Featured')
                    ->placeholder('All products')
                    ->trueLabel('Featured only')
                    ->falseLabel('Not featured'),
                Tables\Filters\TernaryFilter::make('requires_prescription')
                    ->label('Prescription Required')
                    ->placeholder('All products')
                    ->trueLabel('Requires prescription')
                    ->falseLabel('No prescription needed'),
                Tables\Filters\Filter::make('low_stock')
                    ->query(fn (Builder $query): Builder => $query->whereColumn('stock_quantity', '<=', 'low_stock_threshold'))
                    ->label('Low Stock'),
                Tables\Filters\Filter::make('out_of_stock')
                    ->query(fn (Builder $query): Builder => $query->where('stock_quantity', '<=', 0))
                    ->label('Out of Stock'),
                Tables\Filters\TrashedFilter::make(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
                Tables\Actions\RestoreAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\RestoreBulkAction::make(),
                    Tables\Actions\ForceDeleteBulkAction::make(),
                    Tables\Actions\BulkAction::make('markAvailable')
                        ->label('Mark as Available')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(fn ($records) => $records->each->update(['is_available' => true])),
                    Tables\Actions\BulkAction::make('markUnavailable')
                        ->label('Mark as Unavailable')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->action(fn ($records) => $records->each->update(['is_available' => false])),
                    Tables\Actions\BulkAction::make('markFeatured')
                        ->label('Mark as Featured')
                        ->icon('heroicon-o-star')
                        ->color('warning')
                        ->action(fn ($records) => $records->each->update(['is_featured' => true])),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
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

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->withoutGlobalScopes([
                SoftDeletingScope::class,
            ]);
    }
}
