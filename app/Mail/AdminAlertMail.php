<?php

namespace App\Mail;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class AdminAlertMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public string $alertType;
    public array $data;

    /**
     * Create a new message instance.
     */
    public function __construct(string $alertType, array $data = [])
    {
        $this->alertType = $alertType;
        $this->data = $data;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        $subject = match($this->alertType) {
            'no_courier_available' => '⚠️ Alerte: Aucun coursier disponible pour une commande',
            'high_volume' => '📈 Alerte: Volume de commandes élevé',
            'payment_failed' => '❌ Alerte: Échec de paiement',
            'kyc_pending' => '📋 Nouveau KYC en attente de validation',
            'withdrawal_request' => '💰 Nouvelle demande de retrait',
            default => '🔔 Alerte DR-PHARMA',
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
            view: 'emails.admin-alert',
            with: [
                'alertType' => $this->alertType,
                'data' => $this->data,
                'alertTitle' => $this->getAlertTitle(),
            ],
        );
    }

    protected function getAlertTitle(): string
    {
        return match($this->alertType) {
            'no_courier_available' => 'Aucun coursier disponible',
            'high_volume' => 'Volume de commandes élevé',
            'payment_failed' => 'Échec de paiement',
            'kyc_pending' => 'KYC en attente',
            'withdrawal_request' => 'Demande de retrait',
            default => 'Alerte système',
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
