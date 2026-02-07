<?php

namespace App\Filament\Resources\PaymentIntentResource\Pages;

use App\Filament\Resources\PaymentIntentResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreatePaymentIntent extends CreateRecord
{
    protected static string $resource = PaymentIntentResource::class;
}
