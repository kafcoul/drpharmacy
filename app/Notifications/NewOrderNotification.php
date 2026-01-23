<?php

namespace App\Notifications;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class NewOrderNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public Order $order;

    /**
     * Create a new notification instance.
     */
    public function __construct(Order $order)
    {
        $this->order = $order;
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via(object $notifiable): array
    {
        $channels = ['database'];

        if ($notifiable->email) {
            $channels[] = 'mail';
        }

        if ($notifiable->fcm_token) {
            $channels[] = \App\Channels\FcmChannel::class;
        }

        return $channels;
    }

    /**
     * Get the FCM representation of the notification.
     */
    public function toFcm(object $notifiable): array
    {
        return [
            'title' => 'Nouvelle commande 🛒',
            'body' => "Ref: {$this->order->reference} - Total: {$this->order->total_amount} FCFA",
            'data' => [
                'type' => 'new_order',
                'order_id' => (string) $this->order->id,
            ],
        ];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        $customer = $this->order->customer;

        $message = (new MailMessage)
            ->subject("Nouvelle commande - {$this->order->reference}")
            ->greeting("Bonjour,")
            ->line('Vous avez reçu une nouvelle commande!')
            ->line('')
            ->line("**Référence:** {$this->order->reference}")
            ->line("**Client:** {$customer->name}")
            ->line("**Téléphone:** {$this->order->customer_phone}")
            ->line("**Montant:** {$this->order->total_amount} {$this->order->currency}")
            ->line("**Adresse de livraison:** {$this->order->delivery_address}")
            ->line('');

        // Add items
        if ($this->order->items->isNotEmpty()) {
            $message->line('**Articles commandés:**');
            foreach ($this->order->items as $item) {
                $message->line("• {$item->name} x{$item->quantity} - {$item->total_price} XOF");
            }
            $message->line('');
        }

        if ($this->order->customer_notes) {
            $message->line("**Notes du client:** {$this->order->customer_notes}");
        }

        $message->line('')
            ->line('⚠️ Veuillez confirmer cette commande dans les plus brefs délais.')
            ->action('Voir la commande', url("/pharmacy/orders/{$this->order->id}"))
            ->line('Merci!');

        return $message;
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray(object $notifiable): array
    {
        return [
            'order_id' => $this->order->id,
            'order_reference' => $this->order->reference,
            'type' => 'new_order',
            'action' => 'confirm_order',
            'message' => "Nouvelle commande: {$this->order->reference}",
            'order_data' => [
                'customer_name' => $this->order->customer->name,
                'customer_phone' => $this->order->customer_phone,
                'total_amount' => $this->order->total_amount,
                'currency' => $this->order->currency,
                'items_count' => $this->order->items->count(),
                'delivery_address' => $this->order->delivery_address,
            ],
        ];
    }
}
