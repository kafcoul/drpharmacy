<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ProblemReportResource\Pages;
use App\Filament\Resources\ProblemReportResource\RelationManagers;
use App\Models\ProblemReport;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class ProblemReportResource extends Resource
{
    protected static ?string $model = ProblemReport::class;

    protected static ?string $navigationIcon = 'heroicon-o-exclamation-triangle';
    
    protected static ?string $navigationLabel = 'Signalements';
    
    protected static ?string $modelLabel = 'Signalement';
    
    protected static ?string $pluralModelLabel = 'Signalements';
    
    protected static ?string $navigationGroup = 'Support';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('reporter_type')
                    ->label('Type de rapporteur')
                    ->options([
                        'customer' => 'Client',
                        'courier' => 'Livreur',
                        'pharmacy' => 'Pharmacie',
                    ]),
                Forms\Components\TextInput::make('reporter_id')
                    ->label('ID Rapporteur')
                    ->numeric(),
                Forms\Components\Select::make('category')
                    ->label('Catégorie')
                    ->options([
                        'delivery' => 'Livraison',
                        'product' => 'Produit',
                        'service' => 'Service',
                        'payment' => 'Paiement',
                        'other' => 'Autre',
                    ]),
                Forms\Components\Textarea::make('description')
                    ->label('Description')
                    ->columnSpanFull(),
                Forms\Components\Select::make('status')
                    ->label('Statut')
                    ->options([
                        'open' => 'Ouvert',
                        'investigating' => 'En cours',
                        'resolved' => 'Résolu',
                        'closed' => 'Fermé',
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('reporter_type')
                    ->label('Type')
                    ->badge()
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'customer' => 'Client',
                        'courier' => 'Livreur',
                        'pharmacy' => 'Pharmacie',
                        default => $state ?? '-',
                    }),
                Tables\Columns\TextColumn::make('category')
                    ->label('Catégorie')
                    ->badge()
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'delivery' => 'Livraison',
                        'product' => 'Produit',
                        'service' => 'Service',
                        'payment' => 'Paiement',
                        'other' => 'Autre',
                        default => $state ?? '-',
                    }),
                Tables\Columns\TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (?string $state): string => match ($state) {
                        'open' => 'warning',
                        'investigating' => 'info',
                        'resolved' => 'success',
                        'closed' => 'gray',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'open' => 'Ouvert',
                        'investigating' => 'En cours',
                        'resolved' => 'Résolu',
                        'closed' => 'Fermé',
                        default => $state ?? '-',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
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
            'index' => Pages\ListProblemReports::route('/'),
            'create' => Pages\CreateProblemReport::route('/create'),
            'edit' => Pages\EditProblemReport::route('/{record}/edit'),
        ];
    }
}
