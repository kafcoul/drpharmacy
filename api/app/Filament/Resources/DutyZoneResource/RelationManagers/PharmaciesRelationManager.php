<?php

namespace App\Filament\Resources\DutyZoneResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class PharmaciesRelationManager extends RelationManager
{
    protected static string $relationship = 'pharmacies';

    protected static ?string $title = 'Pharmacies de cette zone';

    protected static ?string $recordTitleAttribute = 'name';

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->required()
                    ->maxLength(255),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('name')
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Pharmacie')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),
                Tables\Columns\TextColumn::make('phone')
                    ->label('Téléphone')
                    ->icon('heroicon-o-phone')
                    ->copyable(),
                Tables\Columns\TextColumn::make('address')
                    ->label('Adresse')
                    ->limit(30)
                    ->toggleable(),
                Tables\Columns\TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'approved' => 'success',
                        'pending' => 'warning',
                        'rejected' => 'danger',
                        default => 'gray',
                    }),
                Tables\Columns\IconColumn::make('is_on_duty')
                    ->label('En garde')
                    ->getStateUsing(function ($record): bool {
                        return $record->onCalls()
                            ->where('is_active', true)
                            ->where('start_at', '<=', now())
                            ->where('end_at', '>=', now())
                            ->exists();
                    })
                    ->boolean()
                    ->trueIcon('heroicon-o-shield-check')
                    ->falseIcon('heroicon-o-minus-circle')
                    ->trueColor('success')
                    ->falseColor('gray'),
            ])
            ->filters([
                Tables\Filters\Filter::make('on_duty')
                    ->label('En garde actuellement')
                    ->query(fn (Builder $query): Builder => $query->whereHas('onCalls', function ($q) {
                        $q->where('is_active', true)
                            ->where('start_at', '<=', now())
                            ->where('end_at', '>=', now());
                    }))
                    ->toggle(),
            ])
            ->headerActions([
                // No create action - pharmacies are managed separately
            ])
            ->actions([
                Tables\Actions\Action::make('create_on_call')
                    ->label('Programmer garde')
                    ->icon('heroicon-o-plus-circle')
                    ->color('success')
                    ->url(fn ($record): string => 
                        \App\Filament\Resources\PharmacyOnCallResource::getUrl('create', [
                            'pharmacy_id' => $record->id,
                            'duty_zone_id' => $this->ownerRecord->id,
                        ])
                    ),
                Tables\Actions\Action::make('view')
                    ->label('Voir')
                    ->icon('heroicon-o-eye')
                    ->url(fn ($record): string => 
                        \App\Filament\Resources\PharmacyResource::getUrl('edit', ['record' => $record])
                    ),
            ])
            ->bulkActions([
                // No bulk actions
            ]);
    }
}
