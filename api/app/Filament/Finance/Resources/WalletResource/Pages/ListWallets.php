<?php

namespace App\Filament\Finance\Resources\WalletResource\Pages;

use App\Filament\Finance\Resources\WalletResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListWallets extends ListRecords
{
    protected static string $resource = WalletResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
