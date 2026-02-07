<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PaymentIntentResource\Pages;
use App\Filament\Resources\PaymentIntentResource\RelationManagers;
use App\Models\PaymentIntent;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class PaymentIntentResource extends Resource
{
    protected static ?string $model = PaymentIntent::class;

    protected static ?string $navigationIcon = 'heroicon-o-credit-card';
    
    protected static ?string $navigationLabel = 'Paiements';
    
    protected static ?string $modelLabel = 'Paiement';
    
    protected static ?string $pluralModelLabel = 'Paiements';
    
    protected static ?string $navigationGroup = 'Finance';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('order_id')
                    ->label('Commande')
                    ->relationship('order', 'id')
                    ->required(),
                Forms\Components\TextInput::make('provider')
                    ->label('Fournisseur')
                    ->required(),
                Forms\Components\TextInput::make('reference')
                    ->label('Référence')
                    ->required(),
                Forms\Components\TextInput::make('provider_reference')
                    ->label('Réf. fournisseur'),
                Forms\Components\TextInput::make('provider_transaction_id')
                    ->label('ID transaction'),
                Forms\Components\TextInput::make('amount')
                    ->label('Montant')
                    ->required()
                    ->numeric(),
                Forms\Components\TextInput::make('currency')
                    ->label('Devise')
                    ->required(),
                Forms\Components\Select::make('status')
                    ->label('Statut')
                    ->options([
                        'pending' => 'En attente',
                        'completed' => 'Complété',
                        'failed' => 'Échoué',
                        'cancelled' => 'Annulé',
                    ])
                    ->required(),
                Forms\Components\TextInput::make('provider_payment_url')
                    ->label('URL de paiement'),
                Forms\Components\Textarea::make('raw_response')
                    ->label('Réponse brute')
                    ->columnSpanFull(),
                Forms\Components\Textarea::make('raw_webhook')
                    ->label('Webhook brut')
                    ->columnSpanFull(),
                Forms\Components\DateTimePicker::make('confirmed_at')
                    ->label('Confirmé le'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('order.reference')
                    ->label('Commande')
                    ->sortable(),
                Tables\Columns\TextColumn::make('provider')
                    ->label('Fournisseur')
                    ->searchable(),
                Tables\Columns\TextColumn::make('reference')
                    ->label('Référence')
                    ->searchable(),
                Tables\Columns\TextColumn::make('amount')
                    ->label('Montant')
                    ->money('XOF')
                    ->sortable(),
                Tables\Columns\TextColumn::make('currency')
                    ->label('Devise')
                    ->searchable(),
                Tables\Columns\TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'completed' => 'success',
                        'failed' => 'danger',
                        'cancelled' => 'gray',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'En attente',
                        'completed' => 'Complété',
                        'failed' => 'Échoué',
                        'cancelled' => 'Annulé',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('confirmed_at')
                    ->label('Confirmé le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
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
            'index' => Pages\ListPaymentIntents::route('/'),
            'create' => Pages\CreatePaymentIntent::route('/create'),
            'edit' => Pages\EditPaymentIntent::route('/{record}/edit'),
        ];
    }
}
