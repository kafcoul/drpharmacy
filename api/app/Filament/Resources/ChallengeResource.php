<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ChallengeResource\Pages;
use App\Filament\Resources\ChallengeResource\RelationManagers;
use App\Models\Challenge;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class ChallengeResource extends Resource
{
    protected static ?string $model = Challenge::class;

    protected static ?string $navigationIcon = 'heroicon-o-trophy';
    
    protected static ?string $navigationLabel = 'Défis';
    
    protected static ?string $modelLabel = 'Défi';
    
    protected static ?string $pluralModelLabel = 'Défis';
    
    protected static ?string $navigationGroup = 'Gestion';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->label('Titre')
                    ->required(),
                Forms\Components\Textarea::make('description')
                    ->label('Description')
                    ->required()
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('type')
                    ->label('Type')
                    ->required(),
                Forms\Components\TextInput::make('metric')
                    ->label('Métrique')
                    ->required(),
                Forms\Components\TextInput::make('target_value')
                    ->label('Valeur cible')
                    ->required()
                    ->numeric(),
                Forms\Components\TextInput::make('reward_amount')
                    ->label('Montant récompense')
                    ->required()
                    ->numeric(),
                Forms\Components\TextInput::make('icon')
                    ->label('Icône')
                    ->required(),
                Forms\Components\TextInput::make('color')
                    ->label('Couleur')
                    ->required(),
                Forms\Components\Toggle::make('is_active')
                    ->label('Actif')
                    ->required(),
                Forms\Components\DateTimePicker::make('starts_at')
                    ->label('Début'),
                Forms\Components\DateTimePicker::make('ends_at')
                    ->label('Fin'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('Titre')
                    ->searchable(),
                Tables\Columns\TextColumn::make('type')
                    ->label('Type')
                    ->searchable(),
                Tables\Columns\TextColumn::make('metric')
                    ->label('Métrique')
                    ->searchable(),
                Tables\Columns\TextColumn::make('target_value')
                    ->label('Cible')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('reward_amount')
                    ->label('Récompense')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('icon')
                    ->label('Icône')
                    ->searchable(),
                Tables\Columns\TextColumn::make('color')
                    ->label('Couleur')
                    ->searchable(),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Actif')
                    ->boolean(),
                Tables\Columns\TextColumn::make('starts_at')
                    ->label('Début')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('ends_at')
                    ->label('Fin')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Modifié le')
                    ->dateTime('d/m/Y H:i')
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
            'index' => Pages\ListChallenges::route('/'),
            'create' => Pages\CreateChallenge::route('/create'),
            'edit' => Pages\EditChallenge::route('/{record}/edit'),
        ];
    }
}
