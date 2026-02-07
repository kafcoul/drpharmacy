<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class OtpMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public string $otp;
    public string $purpose;
    public int $validityMinutes;

    /**
     * Create a new message instance.
     */
    public function __construct(string $otp, string $purpose = 'verification', int $validityMinutes = 10)
    {
        $this->otp = $otp;
        $this->purpose = $purpose;
        $this->validityMinutes = $validityMinutes;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        $subject = match($this->purpose) {
            'verification' => 'Vérification de votre compte DR-PHARMA',
            'password_reset' => 'Réinitialisation de votre mot de passe DR-PHARMA',
            'login' => 'Code de connexion DR-PHARMA',
            default => 'Votre code de vérification DR-PHARMA',
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
            view: 'emails.otp',
            with: [
                'otp' => $this->otp,
                'purpose' => $this->purpose,
                'validityMinutes' => $this->validityMinutes,
            ],
        );
    }

    /**
     * Get the attachments for the message.
     */
    public function attachments(): array
    {
        return [];
    }
}
