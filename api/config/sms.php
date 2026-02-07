<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Default SMS Driver
    |--------------------------------------------------------------------------
    |
    | This option controls the default SMS driver that will be used to send
    | SMS messages. Supported: "africastalking", "twilio", "infobip"
    |
    */

    'default' => env('SMS_DRIVER', 'africastalking'),

    /*
    |--------------------------------------------------------------------------
    | Africa's Talking Configuration
    |--------------------------------------------------------------------------
    */

    'africastalking' => [
        'username' => env('AFRICASTALKING_USERNAME', 'sandbox'),
        'api_key' => env('AFRICASTALKING_API_KEY'),
        'sender_id' => env('AFRICASTALKING_SENDER_ID', 'DR-PHARMA'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Twilio Configuration
    |--------------------------------------------------------------------------
    */

    'twilio' => [
        'sid' => env('TWILIO_SID'),
        'token' => env('TWILIO_AUTH_TOKEN'),
        'from' => env('TWILIO_FROM'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Infobip Configuration
    |--------------------------------------------------------------------------
    */

    'infobip' => [
        'base_url' => env('INFOBIP_BASE_URL'),
        'api_key' => env('INFOBIP_API_KEY'),
        'sender' => env('INFOBIP_SENDER', 'DR-PHARMA'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Phone Number Settings
    |--------------------------------------------------------------------------
    |
    | Default country code for phone number normalization
    |
    */

    'default_country_code' => env('SMS_DEFAULT_COUNTRY_CODE', '+225'),

];
