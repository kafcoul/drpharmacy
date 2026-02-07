<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Commission Rates Configuration
    |--------------------------------------------------------------------------
    |
    | These values determine the commission split for each order:
    | - Platform: 10%
    | - Pharmacy: 85%
    | - Courier: 5%
    |
    */

    'platform_rate' => (float) env('COMMISSION_RATE_PLATFORM', 10) / 100,
    'pharmacy_rate' => (float) env('COMMISSION_RATE_PHARMACY', 85) / 100,
    'courier_rate' => (float) env('COMMISSION_RATE_COURIER', 5) / 100,

];
