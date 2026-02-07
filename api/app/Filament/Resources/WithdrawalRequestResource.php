<?php

namespace App\Filament\Resources;

use App\Filament\Resources\WithdrawalRequestResource\Pages;
use App\Filament\Resources\WithdrawalRequestResource\RelationManagers;
use App\Models\WithdrawalRequest;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class WithdrawalRequestResource extends Resource
{
    protected static ?string $model = WithdrawalRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-arrow-up-tray';
    
    protected static ?string $navigationLabel = 'Retraits';
    
    protected static ?string $modelLabel = 'Retrait';
    
    protected static ?string $pluralModelLabel = 'Demandes de retrait';
    
    protected static ?string $navigationGroup = 'Finance';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations du retrait')
                    ->schema([
                        Forms\Components\TextInput::make('wallet_id')
                            ->label('ID Wallet')
                            ->required()
                            ->numeric(),
                        Forms\Components\TextInput::make('pharmacy_id')
                            ->label('ID Pharmacie')
                            ->required()
                            ->numeric(),
                        Forms\Components\TextInput::make('amount')
                            ->label('Montant')
                            ->required()
                            ->numeric()
                            ->prefix('XOF'),
                        Forms\Components\Select::make('payment_method')
                            ->label('Mode de paiement')
                            ->options([
                                'mobile_money' => 'Mobile Money',
                                'bank_transfer' => 'Virement bancaire',
                            ])
                            ->required(),
                        Forms\Components\TextInput::make('phone')
                            ->label('Téléphone')
                            ->tel(),
                    ])->columns(2),
                Forms\Components\Section::make('Détails bancaires')
                    ->schema([
                        Forms\Components\Textarea::make('account_details')
                            ->label('Détails du compte')
                            ->columnSpanFull(),
                        Forms\Components\Textarea::make('bank_details')
                            ->label('Détails bancaires')
                            ->columnSpanFull(),
                    ]),
                Forms\Components\Section::make('Traitement')
                    ->schema([
                        Forms\Components\TextInput::make('reference')
                            ->label('Référence')
                            ->required(),
                        Forms\Components\Select::make('status')
                            ->label('Statut')
                            ->options([
                                'pending' => 'En attente',
                                'processing' => 'En cours',
                                'completed' => 'Complété',
                                'failed' => 'Échoué',
                                'cancelled' => 'Annulé',
                            ])
                            ->required(),
                        Forms\Components\DateTimePicker::make('processed_at')
                            ->label('Traité le'),
                        Forms\Components\DateTimePicker::make('completed_at')
                            ->label('Complété le'),
                        Forms\Components\Textarea::make('admin_notes')
                            ->label('Notes admin')
                            ->columnSpanFull(),
                        Forms\Components\Textarea::make('error_message')
                            ->label('Message d\'erreur')
                            ->columnSpanFull(),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('reference')
                    ->label('Référence')
                    ->searchable(),
                Tables\Columns\TextColumn::make('pharmacy.name')
                    ->label('Pharmacie')
                    ->sortable(),
                Tables\Columns\TextColumn::make('amount')
                    ->label('Montant')
                    ->money('XOF')
                    ->sortable(),
                Tables\Columns\TextColumn::make('payment_method')
                    ->label('Mode')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'mobile_money' => 'Mobile Money',
                        'bank_transfer' => 'Virement',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'processing' => 'info',
                        'completed' => 'success',
                        'failed' => 'danger',
                        'cancelled' => 'gray',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'En attente',
                        'processing' => 'En cours',
                        'completed' => 'Complété',
                        'failed' => 'Échoué',
                        'cancelled' => 'Annulé',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('phone')
                    ->label('Téléphone')
                    ->searchable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('completed_at')
                    ->label('Complété le')
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
            'index' => Pages\ListWithdrawalRequests::route('/'),
            'create' => Pages\CreateWithdrawalRequest::route('/create'),
            'edit' => Pages\EditWithdrawalRequest::route('/{record}/edit'),
        ];
    }
}
