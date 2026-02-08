<?php

use App\Jobs\CheckPendingJekoPayments;
use App\Jobs\CheckWaitingDeliveryTimeouts;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Vérifier les paiements JEKO en attente toutes les 2 minutes
Schedule::job(new CheckPendingJekoPayments(5))->everyTwoMinutes();

// Vérifier les livraisons en attente et annuler celles qui ont dépassé le timeout (chaque minute)
Schedule::job(new CheckWaitingDeliveryTimeouts())->everyMinute();

// Commande manuelle pour vérifier les paiements pending
Artisan::command('jeko:check-pending {--timeout=5 : Timeout en minutes}', function () {
    $timeout = (int) $this->option('timeout');
    $this->info("Vérification des paiements JEKO pending > {$timeout} minutes...");
    
    dispatch(new CheckPendingJekoPayments($timeout));
    
    $this->info('Job dispatched.');
})->purpose('Vérifier les paiements JEKO en attente');

// Commande manuelle pour vérifier les livraisons en timeout
Artisan::command('deliveries:check-timeouts', function () {
    $this->info("Vérification des livraisons en attente dépassant le timeout...");
    
    dispatch(new CheckWaitingDeliveryTimeouts());
    
    $this->info('Job dispatched.');
})->purpose('Vérifier et annuler les livraisons en attente trop longtemps');

// ========================================
// ASSIGNATION AUTOMATIQUE DES LIVRAISONS
// ========================================
// Exécuter l'auto-assignation toutes les minutes (sans intervention humaine)
Schedule::command('deliveries:auto-assign')->everyMinute();

// ========================================
// RELEVÉS AUTOMATIQUES PHARMACIES
// ========================================
// Envoyer les relevés programmés tous les jours à 8h
Schedule::job(new \App\Jobs\SendScheduledStatements())->dailyAt('08:00');

// Commande manuelle pour envoyer les relevés en attente
Artisan::command('statements:send', function () {
    $this->info("Envoi des relevés automatiques programmés...");
    
    dispatch(new \App\Jobs\SendScheduledStatements());
    
    $this->info('Job dispatched.');
})->purpose('Envoyer les relevés automatiques des pharmacies');
