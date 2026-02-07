<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PayoutRequestResource\Pages;
use App\Filament\Resources\PayoutRequestResource\RelationManagers;
use App\Models\PayoutRequest;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class PayoutRequestResource extends Resource
{
    protected static ?string $model = PayoutRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-banknotes';
    
    protected static ?string $navigationLabel = 'Versements';
    
    protected static ?string $modelLabel = 'Versement';
    
    protected static ?string $pluralModelLabel = 'Demandes de versement';
    
    protected static ?string $navigationGroup = 'Finance';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('wallet_id')
                    ->label('ID Wallet')
                    ->required()
                    ->numeric(),
                Forms\Components\TextInput::make('amount')
                    ->label('Montant')
                    ->required()
                    ->numeric()
                    ->prefix('XOF'),
                Forms\Components\Select::make('status')
                    ->label('Statut')
                    ->options([
                        'pending' => 'En attente',
                        'approved' => 'Approuvé',
                        'rejected' => 'Rejeté',
                        'completed' => 'Complété',
                    ])
                    ->required(),
                Forms\Components\Select::make('payment_method')
                    ->label('Mode de paiement')
                    ->options([
                        'mobile_money' => 'Mobile Money',
                        'bank_transfer' => 'Virement bancaire',
                    ])
                    ->required(),
                Forms\Components\Textarea::make('payment_details')
                    ->label('Détails de paiement')
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('rejection_reason')
                    ->label('Motif de rejet'),
                Forms\Components\DateTimePicker::make('processed_at')
                    ->label('Traité le'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('wallet_id')
                    ->label('Wallet')
                    ->sortable(),
                Tables\Columns\TextColumn::make('amount')
                    ->label('Montant')
                    ->money('XOF')
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'approved' => 'info',
                        'rejected' => 'danger',
                        'completed' => 'success',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'En attente',
                        'approved' => 'Approuvé',
                        'rejected' => 'Rejeté',
                        'completed' => 'Complété',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('payment_method')
                    ->label('Mode')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'mobile_money' => 'Mobile Money',
                        'bank_transfer' => 'Virement',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('rejection_reason')
                    ->label('Motif rejet')
                    ->limit(20),
                Tables\Columns\TextColumn::make('processed_at')
                    ->label('Traité le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
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
            'index' => Pages\ListPayoutRequests::route('/'),
            'create' => Pages\CreatePayoutRequest::route('/create'),
            'edit' => Pages\EditPayoutRequest::route('/{record}/edit'),
        ];
    }
}
