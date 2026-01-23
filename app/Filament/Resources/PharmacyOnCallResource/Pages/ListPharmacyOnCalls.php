<?php

namespace App\Filament\Resources\PharmacyOnCallResource\Pages;

use App\Filament\Resources\PharmacyOnCallResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListPharmacyOnCalls extends ListRecords
{
    protected static string $resource = PharmacyOnCallResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
