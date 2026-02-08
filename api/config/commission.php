<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Commission Rates Configuration
    |--------------------------------------------------------------------------
    |
    | NOUVEAU SYSTÈME:
    | - La pharmacie reçoit 100% du prix des médicaments qu'elle a fixé
    | - La plateforme ajoute 2% au prix pour sa commission (payé par le client)
    | - Les frais de livraison vont au coursier (moins commission fixe)
    |
    */

    // Commission plateforme: 2% ajouté au prix des médicaments
    'platform_rate' => (float) env('COMMISSION_RATE_PLATFORM', 2) / 100,
    
    // Pharmacie reçoit 100% du prix des médicaments
    'pharmacy_rate' => (float) env('COMMISSION_RATE_PHARMACY', 100) / 100,
    
    // Coursier: reçoit les frais de livraison (géré séparément)
    'courier_rate' => (float) env('COMMISSION_RATE_COURIER', 0) / 100,

];

