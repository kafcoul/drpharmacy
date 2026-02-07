<?php

namespace App\Filament\Resources\PaymentIntentResource\Pages;

use App\Filament\Resources\PaymentIntentResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListPaymentIntents extends ListRecords
{
    protected static string $resource = PaymentIntentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
