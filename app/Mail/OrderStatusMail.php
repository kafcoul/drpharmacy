<?php

namespace App\Mail;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class OrderStatusMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public Order $order;
    public string $status;
    public ?string $message;

    /**
     * Create a new message instance.
     */
    public function __construct(Order $order, string $status, ?string $message = null)
    {
        $this->order = $order;
        $this->status = $status;
        $this->message = $message;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        $subject = match($this->status) {
            'confirmed' => "Commande #{$this->order->id} confirmée",
            'ready' => "Commande #{$this->order->id} prête pour livraison",
            'picked_up' => "Commande #{$this->order->id} en cours de livraison",
            'delivered' => "Commande #{$this->order->id} livrée avec succès",
            'cancelled' => "Commande #{$this->order->id} annulée",
            default => "Mise à jour de votre commande #{$this->order->id}",
        };

        return new Envelope(
            subject: $subject,
        );
    }

    /**
     * Get the message content definition.
     */
    public function content(): Content
    {
        return new Content(
            view: 'emails.order-status',
            with: [
                'order' => $this->order,
                'status' => $this->status,
                'message' => $this->message,
                'statusLabel' => $this->getStatusLabel(),
            ],
        );
    }

    protected function getStatusLabel(): string
    {
        return match($this->status) {
            'pending' => 'En attente',
            'confirmed' => 'Confirmée',
            'ready' => 'Prête',
            'picked_up' => 'En livraison',
            'delivered' => 'Livrée',
            'cancelled' => 'Annulée',
            default => ucfirst($this->status),
        };
    }

    /**
     * Get the attachments for the message.
     */
    public function attachments(): array
    {
        return [];
    }
}
