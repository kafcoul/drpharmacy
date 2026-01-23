<?php

namespace App\Filament\Support\Resources\OrderResource\Pages;

use App\Filament\Support\Resources\OrderResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateOrder extends CreateRecord
{
    protected static string $resource = OrderResource::class;
}
