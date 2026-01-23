<?php

namespace App\Filament\Resources\PharmacyOnCallResource\Pages;

use App\Filament\Resources\PharmacyOnCallResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditPharmacyOnCall extends EditRecord
{
    protected static string $resource = PharmacyOnCallResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
