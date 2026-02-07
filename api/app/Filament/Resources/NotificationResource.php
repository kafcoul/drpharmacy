<?php

namespace App\Filament\Resources;

use App\Filament\Resources\NotificationResource\Pages;
use App\Filament\Resources\NotificationResource\RelationManagers;
use App\Models\Notification;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class NotificationResource extends Resource
{
    protected static ?string $model = Notification::class;

    protected static ?string $navigationIcon = 'heroicon-o-bell';
    
    protected static ?string $navigationLabel = 'Notifications';
    
    protected static ?string $modelLabel = 'Notification';
    
    protected static ?string $pluralModelLabel = 'Notifications';
    
    protected static ?string $navigationGroup = 'Administration';

    public static function canCreate(): bool
    {
        return false;
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('type')
                    ->label('Type')
                    ->disabled(),
                Forms\Components\TextInput::make('notifiable_type')
                    ->label('Destinataire (Type)')
                    ->disabled(),
                Forms\Components\TextInput::make('notifiable_id')
                    ->label('Destinataire (ID)')
                    ->disabled(),
                Forms\Components\KeyValue::make('data')
                    ->label('Données')
                    ->disabled()
                    ->columnSpanFull(),
                Forms\Components\DateTimePicker::make('read_at')
                    ->label('Lu le')
                    ->disabled(),
                Forms\Components\DateTimePicker::make('created_at')
                    ->label('Envoyé le')
                    ->disabled(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Date')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('notifiable_type')
                    ->label('Type Destinataire')
                    ->formatStateUsing(fn ($state) => class_basename($state))
                    ->badge(),
                Tables\Columns\TextColumn::make('data')
                    ->label('Message')
                    ->limit(50)
                    ->tooltip(fn ($record) => json_encode($record->data)),
                Tables\Columns\IconColumn::make('read_at')
                    ->label('Lu')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-x-circle')
                    ->color(fn ($state) => $state ? 'success' : 'danger'),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
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
            'index' => Pages\ListNotifications::route('/'),
        ];
    }
}
