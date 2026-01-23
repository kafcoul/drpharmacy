<?php

namespace App\Channels;

use Illuminate\Notifications\Notification;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\AndroidConfig;
use Kreait\Firebase\Messaging\ApnsConfig;

class FcmChannel
{
    protected $messaging;

    public function __construct(Messaging $messaging)
    {
        $this->messaging = $messaging;
    }

    /**
     * Send the given notification.
     */
    public function send(object $notifiable, Notification $notification): void
    {
        if (!method_exists($notification, 'toFcm')) {
            return;
        }

        $token = $notifiable->fcm_token;
        if (!$token) {
            return;
        }

        /** @var mixed $notification */
        $data = $notification->toFcm($notifiable);

        try {
            $message = CloudMessage::withTarget('token', $token)
                ->withNotification(\Kreait\Firebase\Messaging\Notification::create(
                    $data['title'] ?? config('app.name'),
                    $data['body'] ?? ''
                ))
                ->withData(array_merge($data['data'] ?? [], [
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ]));

            // Configuration Android avancée (sonnerie, vibration, priorité)
            if (isset($data['android']) || isset($data['data']['android_channel_id'])) {
                $androidConfig = [
                    'priority' => $data['android']['priority'] ?? 'high',
                    'notification' => [
                        'channel_id' => $data['data']['android_channel_id'] ?? 'default',
                        'sound' => $data['data']['sound'] ?? 'default',
                    ],
                ];
                
                // Ajouter les configurations de vibration si présentes
                if (isset($data['android']['notification'])) {
                    $androidConfig['notification'] = array_merge(
                        $androidConfig['notification'],
                        $data['android']['notification']
                    );
                }
                
                $message = $message->withAndroidConfig(AndroidConfig::fromArray($androidConfig));
            }

            // Configuration iOS/APNs avancée
            if (isset($data['apns'])) {
                $message = $message->withApnsConfig(ApnsConfig::fromArray($data['apns']));
            }

            $this->messaging->send($message);
            
            Log::info('FCM Notification sent', [
                'token' => substr($token, 0, 20) . '...',
                'title' => $data['title'] ?? 'N/A',
                'type' => $data['data']['type'] ?? 'unknown',
            ]);

        } catch (\Kreait\Firebase\Exception\MessagingException $e) {
            Log::error('FCM Send Error: ' . $e->getMessage(), [
                'token' => substr($token, 0, 20) . '...',
            ]);
        } catch (\Throwable $e) {
            Log::error('FCM Exception: ' . $e->getMessage(), [
                'token' => substr($token, 0, 20) . '...',
            ]);
        }
    }
}
