<?php

return [
    App\Providers\AppServiceProvider::class,
    App\Providers\Filament\AdminPanelProvider::class,
    App\Providers\Filament\FinancePanelProvider::class,
    App\Providers\Filament\PharmacyPanelProvider::class,
    App\Providers\Filament\SupportPanelProvider::class,
    App\Providers\SmsServiceProvider::class,
    // TelescopeServiceProvider est chargé conditionnellement dans AppServiceProvider (local only)
];
