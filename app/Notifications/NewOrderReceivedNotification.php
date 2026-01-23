<?php

namespace App\Notifications;

use App\Models\Order;
use App\Channels\FcmChannel;
use App\Services\NotificationSettingsService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

/**
 * Notification envoyée à la pharmacie quand une nouvelle commande est reçue
 */
class NewOrderReceivedNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(
        public Order $order
    ) {}

    public function via($notifiable): array
    {
        return ['database', FcmChannel::class];
    }

    public function toDatabase($notifiable): array
    {
        $itemsCount = $this->order->items->count();
        
        return [
            'type' => 'new_order_received',
            'order_id' => $this->order->id,
            'order_reference' => $this->order->reference,
            'customer_name' => $this->order->customer?->name,
            'customer_phone' => $this->order->customer_phone,
            'items_count' => $itemsCount,
            'total_amount' => $this->order->total_amount,
            'payment_mode' => $this->order->payment_mode,
            'delivery_address' => $this->order->delivery_address,
            'has_prescription' => !empty($this->order->prescription_image),
            'customer_notes' => $this->order->customer_notes,
            'message' => "🛒 Nouvelle commande #{$this->order->reference} - {$itemsCount} article(s) - {$this->order->total_amount} FCFA",
        ];
    }

    public function toFcm($notifiable): array
    {
        $itemsCount = $this->order->items->count();
        $paymentLabel = match($this->order->payment_mode) {
            'cash' => 'Espèces',
            'mobile_money' => 'Mobile Money',
            'card' => 'Carte bancaire',
            default => $this->order->payment_mode,
        };

        // Récupérer les paramètres de notification depuis la config admin
        $fcmConfig = NotificationSettingsService::getFcmConfig('new_order');

        $body = "Client: {$this->order->customer?->name}\n" .
                "{$itemsCount} article(s) - {$this->order->total_amount} FCFA\n" .
                "Paiement: {$paymentLabel}";

        if ($this->order->customer_notes) {
            $body .= "\n📝 Note: " . substr($this->order->customer_notes, 0, 50);
        }

        if (!empty($this->order->prescription_image)) {
            $body .= "\n📋 Ordonnance jointe";
        }

        return [
            'title' => "🛒 Nouvelle commande #{$this->order->reference}",
            'body' => $body,
            'data' => array_merge([
                'type' => 'new_order_received',
                'order_id' => (string) $this->order->id,
                'order_reference' => $this->order->reference,
                'customer_name' => $this->order->customer?->name ?? '',
                'customer_phone' => $this->order->customer_phone ?? '',
                'items_count' => (string) $itemsCount,
                'total_amount' => (string) $this->order->total_amount,
                'payment_mode' => $this->order->payment_mode,
                'has_prescription' => !empty($this->order->prescription_image) ? 'true' : 'false',
                'click_action' => 'ORDER_DETAIL',
            ], $fcmConfig['data']),
            'android' => $fcmConfig['android'],
            'apns' => $fcmConfig['apns'],
        ];
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray($notifiable): array
    {
        return $this->toDatabase($notifiable);
    }
}
