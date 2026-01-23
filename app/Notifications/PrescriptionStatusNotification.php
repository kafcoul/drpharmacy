<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use App\Models\Prescription;

class PrescriptionStatusNotification extends Notification implements ShouldQueue
{
    use Queueable;

    protected $prescription;
    protected $status;

    /**
     * Create a new notification instance.
     */
    public function __construct(Prescription $prescription, string $status)
    {
        $this->prescription = $prescription;
        $this->status = $status;
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via(object $notifiable): array
    {
        $channels = ['database'];
        if ($notifiable->fcm_token) {
            $channels[] = \App\Channels\FcmChannel::class;
        }
        return $channels;
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray(object $notifiable): array
    {
        return [
            'title' => 'Mise à jour Ordonnance',
            'body' => $this->getMessage(),
            'prescription_id' => $this->prescription->id,
            'status' => $this->status,
            'type' => 'prescription_status',
        ];
    }

    /**
     * Get the FCM representation of the notification.
     */
    public function toFcm(object $notifiable): array
    {
        return [
            'title' => 'Mise à jour Ordonnance',
            'body' => $this->getMessage(),
            'data' => [
                'type' => 'prescription_status',
                'prescription_id' => (string) $this->prescription->id,
                'status' => $this->status,
            ],
        ];
    }

    private function getMessage(): string
    {
        switch ($this->status) {
            case 'quoted':
                return 'Une pharmacie a envoyé un devis pour votre ordonnance.';
            case 'validated':
                return 'Votre ordonnance a été validée.';
            case 'rejected':
                return 'Votre ordonnance a été refusée.';
            default:
                return 'Le statut de votre ordonnance a changé: ' . $this->status;
        }
    }
}
