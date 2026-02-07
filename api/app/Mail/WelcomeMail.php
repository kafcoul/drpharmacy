<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class WelcomeMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public string $userName;
    public string $userType;

    /**
     * Create a new message instance.
     */
    public function __construct(string $userName, string $userType = 'customer')
    {
        $this->userName = $userName;
        $this->userType = $userType;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Bienvenue sur DR-PHARMA ! 🎉',
        );
    }

    /**
     * Get the message content definition.
     */
    public function content(): Content
    {
        return new Content(
            view: 'emails.welcome',
            with: [
                'userName' => $this->userName,
                'userType' => $this->userType,
                'userTypeLabel' => $this->getUserTypeLabel(),
            ],
        );
    }

    protected function getUserTypeLabel(): string
    {
        return match($this->userType) {
            'customer' => 'Client',
            'pharmacy' => 'Pharmacie',
            'courier' => 'Livreur',
            default => 'Utilisateur',
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
