<?php

namespace App\Notifications;

use App\Channels\FcmChannel;
use App\Models\Delivery;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

class NewChatMessageNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(
        public Delivery $delivery,
        public string $senderName,
        public string $senderType,
        public string $message
    ) {}

    public function via($notifiable): array
    {
        return [FcmChannel::class, 'database'];
    }

    public function toFcm($notifiable): array
    {
        $senderLabel = match($this->senderType) {
            'courier' => 'Livreur',
            'pharmacy' => 'Pharmacie',
            'client' => 'Client',
            default => 'Utilisateur',
        };

        return [
            'title' => "💬 Nouveau message - {$senderLabel}",
            'body' => "{$this->senderName}: " . substr($this->message, 0, 100) . (strlen($this->message) > 100 ? '...' : ''),
            'data' => [
                'type' => 'chat_message',
                'delivery_id' => (string) $this->delivery->id,
                'sender_type' => $this->senderType,
                'sender_name' => $this->senderName,
            ],
        ];
    }

    public function toArray($notifiable): array
    {
        return [
            'type' => 'chat_message',
            'delivery_id' => $this->delivery->id,
            'sender_type' => $this->senderType,
            'sender_name' => $this->senderName,
            'message' => $this->message,
            'message_preview' => substr($this->message, 0, 100),
        ];
    }
}
