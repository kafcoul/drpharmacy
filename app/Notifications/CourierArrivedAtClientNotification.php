<?php

namespace App\Notifications;

use App\Models\Delivery;
use App\Channels\FcmChannel;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

/**
 * Notification envoyée à la pharmacie quand le coursier arrive chez le client
 * Inclut les informations du compte à rebours
 */
class CourierArrivedAtClientNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(
        public Delivery $delivery,
        public int $timeoutMinutes,
        public int $feePerMinute
    ) {}

    public function via($notifiable): array
    {
        return ['database', FcmChannel::class];
    }

    public function toDatabase($notifiable): array
    {
        return [
            'type' => 'courier_arrived_at_client',
            'delivery_id' => $this->delivery->id,
            'order_id' => $this->delivery->order_id,
            'order_reference' => $this->delivery->order?->reference,
            'courier_name' => $this->delivery->courier?->name,
            'message' => "Le coursier est arrivé chez le client pour la commande #{$this->delivery->order?->reference}",
            'countdown_started_at' => $this->delivery->waiting_started_at?->toISOString(),
            'timeout_minutes' => $this->timeoutMinutes,
            'fee_per_minute' => $this->feePerMinute,
            'warning' => "Le client dispose de {$this->timeoutMinutes} minutes pour récupérer sa commande",
        ];
    }

    public function toFcm($notifiable): array
    {
        return [
            'title' => 'Coursier arrivé chez le client',
            'body' => "Le coursier est arrivé chez le client pour la commande #{$this->delivery->order?->reference}. Compte à rebours de {$this->timeoutMinutes} minutes démarré.",
            'data' => [
                'type' => 'courier_arrived_at_client',
                'delivery_id' => (string) $this->delivery->id,
                'order_id' => (string) $this->delivery->order_id,
                'order_reference' => $this->delivery->order?->reference,
                'countdown_started_at' => $this->delivery->waiting_started_at?->toISOString(),
                'timeout_minutes' => (string) $this->timeoutMinutes,
                'fee_per_minute' => (string) $this->feePerMinute,
                'click_action' => 'ORDER_DETAIL',
            ],
        ];
    }
}
