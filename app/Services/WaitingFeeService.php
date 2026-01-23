<?php

namespace App\Services;

use App\Models\Delivery;
use App\Models\Setting;
use Carbon\Carbon;

class WaitingFeeService
{
    /**
     * Récupérer les paramètres de minuterie
     */
    public function getSettings(): array
    {
        return [
            'timeout_minutes' => Setting::get('waiting_timeout_minutes', 10),
            'fee_per_minute' => Setting::get('waiting_fee_per_minute', 100),
            'free_minutes' => Setting::get('waiting_free_minutes', 2),
        ];
    }

    /**
     * Démarrer le compteur d'attente pour une livraison
     */
    public function startWaiting(Delivery $delivery): Delivery
    {
        if ($delivery->waiting_started_at) {
            return $delivery; // Déjà en attente
        }

        $delivery->update([
            'waiting_started_at' => Carbon::now(),
        ]);

        return $delivery->fresh();
    }

    /**
     * Arrêter le compteur d'attente et calculer les frais finaux
     */
    public function stopWaiting(Delivery $delivery, bool $delivered = true): Delivery
    {
        if (!$delivery->waiting_started_at || $delivery->waiting_ended_at) {
            return $delivery; // Pas d'attente en cours
        }

        $settings = $this->getSettings();
        $waitingFee = $this->calculateCurrentFee($delivery);

        $delivery->update([
            'waiting_ended_at' => Carbon::now(),
            'waiting_fee' => $waitingFee,
        ]);

        return $delivery->fresh();
    }

    /**
     * Calculer les frais d'attente actuels pour une livraison
     */
    public function calculateCurrentFee(Delivery $delivery): int
    {
        if (!$delivery->waiting_started_at) {
            return 0;
        }

        $settings = $this->getSettings();
        $waitingStarted = Carbon::parse($delivery->waiting_started_at);
        $endTime = $delivery->waiting_ended_at 
            ? Carbon::parse($delivery->waiting_ended_at) 
            : Carbon::now();
        
        $waitingMinutes = $waitingStarted->diffInMinutes($endTime);
        
        // Minutes facturables = total - gratuites
        $billableMinutes = max(0, $waitingMinutes - $settings['free_minutes']);
        
        return $billableMinutes * $settings['fee_per_minute'];
    }

    /**
     * Obtenir le temps d'attente restant avant annulation automatique
     */
    public function getRemainingTime(Delivery $delivery): ?int
    {
        if (!$delivery->waiting_started_at || $delivery->waiting_ended_at) {
            return null;
        }

        $settings = $this->getSettings();
        $waitingStarted = Carbon::parse($delivery->waiting_started_at);
        $waitingMinutes = $waitingStarted->diffInMinutes(Carbon::now());
        
        $remaining = $settings['timeout_minutes'] - $waitingMinutes;
        
        return max(0, $remaining);
    }

    /**
     * Vérifier si une livraison a dépassé le timeout
     */
    public function hasTimedOut(Delivery $delivery): bool
    {
        if (!$delivery->waiting_started_at || $delivery->waiting_ended_at) {
            return false;
        }

        $settings = $this->getSettings();
        $waitingStarted = Carbon::parse($delivery->waiting_started_at);
        $waitingMinutes = $waitingStarted->diffInMinutes(Carbon::now());
        
        return $waitingMinutes >= $settings['timeout_minutes'];
    }

    /**
     * Obtenir les informations d'attente complètes pour une livraison
     */
    public function getWaitingInfo(Delivery $delivery): array
    {
        $settings = $this->getSettings();
        
        if (!$delivery->waiting_started_at) {
            return [
                'is_waiting' => false,
                'waiting_started_at' => null,
                'waiting_ended_at' => null,
                'waiting_minutes' => 0,
                'waiting_fee' => 0,
                'remaining_minutes' => null,
                'free_minutes' => $settings['free_minutes'],
                'fee_per_minute' => $settings['fee_per_minute'],
                'timeout_minutes' => $settings['timeout_minutes'],
            ];
        }

        $waitingStarted = Carbon::parse($delivery->waiting_started_at);
        $endTime = $delivery->waiting_ended_at 
            ? Carbon::parse($delivery->waiting_ended_at) 
            : Carbon::now();
        
        $waitingMinutes = $waitingStarted->diffInMinutes($endTime);
        $waitingSeconds = $waitingStarted->diffInSeconds($endTime) % 60;
        
        return [
            'is_waiting' => !$delivery->waiting_ended_at && !$delivery->auto_cancelled_at,
            'waiting_started_at' => $delivery->waiting_started_at,
            'waiting_ended_at' => $delivery->waiting_ended_at,
            'waiting_minutes' => $waitingMinutes,
            'waiting_seconds' => $waitingSeconds,
            'waiting_fee' => $this->calculateCurrentFee($delivery),
            'remaining_minutes' => $this->getRemainingTime($delivery),
            'free_minutes' => $settings['free_minutes'],
            'fee_per_minute' => $settings['fee_per_minute'],
            'timeout_minutes' => $settings['timeout_minutes'],
            'auto_cancelled' => (bool) $delivery->auto_cancelled_at,
            'cancellation_reason' => $delivery->cancellation_reason,
        ];
    }
}
