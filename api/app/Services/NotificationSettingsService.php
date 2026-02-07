<?php

namespace App\Services;

use App\Models\Setting;

/**
 * Service pour gérer les paramètres de notification
 */
class NotificationSettingsService
{
    /**
     * Récupère les paramètres de sonnerie pour un type de notification
     */
    public static function getSoundSettings(string $notificationType): array
    {
        $soundKey = match($notificationType) {
            'delivery_assigned' => 'sound_delivery_assigned',
            'new_order' => 'sound_new_order',
            'courier_arrived' => 'sound_courier_arrived',
            'delivery_timeout' => 'sound_delivery_timeout',
            default => 'default',
        };

        $sound = Setting::get($soundKey, 'default');
        $vibrateEnabled = Setting::get('notification_vibrate_enabled', true);
        $ledEnabled = Setting::get('notification_led_enabled', true);
        $ledColor = Setting::get('notification_led_color', '#FF6B00');

        return [
            'sound' => $sound === 'none' ? null : $sound,
            'vibrate' => $vibrateEnabled,
            'led_enabled' => $ledEnabled,
            'led_color' => $ledColor,
            'priority' => self::getPriorityForType($notificationType),
            'channel_id' => self::getChannelForType($notificationType),
        ];
    }

    /**
     * Détermine la priorité selon le type de notification
     */
    protected static function getPriorityForType(string $type): string
    {
        return match($type) {
            'delivery_assigned' => 'high',
            'new_order' => 'high',
            'courier_arrived' => 'high',
            'delivery_timeout' => 'high',
            default => 'default',
        };
    }

    /**
     * Détermine le channel Android selon le type de notification
     */
    protected static function getChannelForType(string $type): string
    {
        return match($type) {
            'delivery_assigned' => 'delivery_alerts',
            'new_order' => 'order_alerts',
            'courier_arrived' => 'courier_alerts',
            'delivery_timeout' => 'timeout_alerts',
            default => 'default',
        };
    }

    /**
     * Convertit la couleur hex en tableau RGB pour Firebase
     */
    public static function hexToRgb(string $hex): array
    {
        $hex = ltrim($hex, '#');
        
        return [
            'red' => hexdec(substr($hex, 0, 2)) / 255,
            'green' => hexdec(substr($hex, 2, 2)) / 255,
            'blue' => hexdec(substr($hex, 4, 2)) / 255,
        ];
    }

    /**
     * Génère la configuration FCM complète pour un type de notification
     */
    public static function getFcmConfig(string $notificationType): array
    {
        $settings = self::getSoundSettings($notificationType);
        $ledRgb = self::hexToRgb($settings['led_color']);

        $config = [
            'data' => [
                'sound' => $settings['sound'] ?? 'default',
                'priority' => $settings['priority'],
                'android_channel_id' => $settings['channel_id'],
                'vibrate' => $settings['vibrate'] ? 'true' : 'false',
                'lights' => $settings['led_enabled'] ? 'true' : 'false',
            ],
        ];

        // Configuration Android
        $androidNotification = [
            'channel_id' => $settings['channel_id'],
        ];

        if ($settings['sound'] && $settings['sound'] !== 'none') {
            $androidNotification['sound'] = $settings['sound'];
        }

        if ($settings['vibrate']) {
            $androidNotification['default_vibrate_timings'] = false;
            $androidNotification['vibrate_timings'] = ['0.5s', '0.3s', '0.5s'];
        }

        if ($settings['led_enabled']) {
            $androidNotification['default_light_settings'] = false;
            $androidNotification['light_settings'] = [
                'color' => $ledRgb,
                'light_on_duration' => '0.5s',
                'light_off_duration' => '0.5s',
            ];
        }

        $config['android'] = [
            'priority' => $settings['priority'],
            'notification' => $androidNotification,
        ];

        // Configuration iOS/APNs
        $apsPayload = [
            'badge' => 1,
            'content-available' => 1,
        ];

        if ($settings['sound'] && $settings['sound'] !== 'none') {
            $apsPayload['sound'] = $settings['sound'] . '.wav';
        }

        $config['apns'] = [
            'payload' => [
                'aps' => $apsPayload,
            ],
        ];

        return $config;
    }

    /**
     * Liste des sons disponibles (pour API)
     */
    public static function getAvailableSounds(): array
    {
        return [
            ['id' => 'default', 'name' => 'Par défaut', 'icon' => '🔔'],
            ['id' => 'delivery_alert', 'name' => 'Alerte livraison', 'icon' => '🚨'],
            ['id' => 'order_received', 'name' => 'Commande reçue', 'icon' => '🛒'],
            ['id' => 'courier_arrived', 'name' => 'Arrivée livreur', 'icon' => '📍'],
            ['id' => 'timeout_alert', 'name' => 'Alerte timeout', 'icon' => '⏰'],
            ['id' => 'success_chime', 'name' => 'Succès', 'icon' => '✅'],
            ['id' => 'warning_tone', 'name' => 'Avertissement', 'icon' => '⚠️'],
            ['id' => 'urgent_bell', 'name' => 'Cloche urgente', 'icon' => '🔔'],
            ['id' => 'soft_notification', 'name' => 'Notification douce', 'icon' => '🔕'],
            ['id' => 'cash_register', 'name' => 'Caisse enregistreuse', 'icon' => '💰'],
            ['id' => 'doorbell', 'name' => 'Sonnette', 'icon' => '🚪'],
            ['id' => 'message_tone', 'name' => 'Ton de message', 'icon' => '💬'],
            ['id' => 'none', 'name' => 'Silencieux', 'icon' => '🔇'],
        ];
    }
}
