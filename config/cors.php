<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure your settings for cross-origin resource sharing
    | or "CORS". This determines what cross-origin operations may execute
    | in web browsers. You are free to adjust these settings as needed.
    |
    | To learn more: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie', 'broadcasting/auth'],

    'allowed_methods' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],

    'allowed_origins' => env('APP_ENV') === 'local' ? ['*'] : array_filter([
        env('FRONTEND_URL'),
        env('ADMIN_URL'),
        env('APP_URL'),
    ]),

    'allowed_origins_patterns' => env('APP_ENV') === 'local' ? [] : [
        // Pattern pour les apps mobiles et sous-domaines
        '#^https://.*\.dr-pharma\.com$#',
    ],

    'allowed_headers' => [
        'Content-Type',
        'X-Requested-With',
        'Authorization',
        'Accept',
        'Origin',
        'X-CSRF-TOKEN',
    ],

    'exposed_headers' => ['X-RateLimit-Limit', 'X-RateLimit-Remaining'],

    'max_age' => 86400, // 24 heures

    'supports_credentials' => true,

];
