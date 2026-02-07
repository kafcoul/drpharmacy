<?php

namespace App\Channels;

use Illuminate\Notifications\Notification;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class SmsChannel
{
    /**
     * Send the given notification.
     * 
     * Notifications using this channel must implement a toSms() method
     * that returns the SMS message text.
     * 
     * @param object $notifiable
     * @param \Illuminate\Notifications\Notification $notification
     * @return void
     */
    public function send(object $notifiable, Notification $notification): void
    {
        // Check if notification implements toSms() method
        if (! method_exists($notification, 'toSms')) {
            return;
        }

        /** @var string|null $message */
        // @phpcs:ignore Intelephense
        $message = call_user_func([$notification, 'toSms'], $notifiable);

        if (! $message) {
            return;
        }

        $phone = $this->getPhoneNumber($notifiable);

        if (! $phone) {
            Log::warning('No phone number found for SMS notification', [
                'notifiable_type' => get_class($notifiable),
                'notifiable_id' => $notifiable->id,
            ]);
            return;
        }

        $this->sendSms($phone, $message);
    }

    /**
     * Get phone number from notifiable
     */
    protected function getPhoneNumber(object $notifiable): ?string
    {
        // Try different phone fields
        return $notifiable->phone 
            ?? $notifiable->mobile 
            ?? $notifiable->phone_number 
            ?? null;
    }

    /**
     * Send SMS via Africa's Talking API
     */
    protected function sendSms(string $phone, string $message): void
    {
        $provider = config('services.sms.provider', 'africas_talking');

        match ($provider) {
            'africas_talking' => $this->sendViaAfricasTalking($phone, $message),
            'twilio' => $this->sendViaTwilio($phone, $message),
            'log' => $this->sendViaLog($phone, $message),
            default => Log::warning("Unknown SMS provider: {$provider}"),
        };
    }

    /**
     * Send SMS via Africa's Talking
     */
    protected function sendViaAfricasTalking(string $phone, string $message): void
    {
        $apiKey = config('services.africas_talking.api_key');
        $username = config('services.africas_talking.username');

        if (! $apiKey || ! $username) {
            Log::warning('Africa\'s Talking credentials not configured');
            return;
        }

        try {
            /** @var \Illuminate\Http\Client\Response $response */
            $response = Http::withHeaders([
                'ApiKey' => $apiKey,
                'Content-Type' => 'application/x-www-form-urlencoded',
                'Accept' => 'application/json',
            ])->asForm()->post('https://api.africastalking.com/version1/messaging', [
                'username' => $username,
                'to' => $phone,
                'message' => $message,
                'from' => config('services.africas_talking.sender_id', 'DR-PHARMA'),
            ]);

            if ($response->successful()) {
                Log::info('SMS sent successfully via Africa\'s Talking', [
                    'phone' => $phone,
                    'response' => $response->json(),
                ]);
            } else {
                Log::error('Failed to send SMS via Africa\'s Talking', [
                    'phone' => $phone,
                    'status' => $response->status(),
                    'response' => $response->body(),
                ]);
            }
        } catch (\Exception $e) {
            Log::error('Exception sending SMS via Africa\'s Talking', [
                'phone' => $phone,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Send SMS via Twilio
     */
    protected function sendViaTwilio(string $phone, string $message): void
    {
        $accountSid = config('services.twilio.account_sid');
        $authToken = config('services.twilio.auth_token');
        $fromNumber = config('services.twilio.from_number');

        if (! $accountSid || ! $authToken || ! $fromNumber) {
            Log::warning('Twilio credentials not configured');
            return;
        }

        try {
            /** @var \Illuminate\Http\Client\Response $response */
            $response = Http::withBasicAuth($accountSid, $authToken)
                ->asForm()
                ->post("https://api.twilio.com/2010-04-01/Accounts/{$accountSid}/Messages.json", [
                    'To' => $phone,
                    'From' => $fromNumber,
                    'Body' => $message,
                ]);

            if ($response->successful()) {
                Log::info('SMS sent successfully via Twilio', [
                    'phone' => $phone,
                    'sid' => $response->json('sid'),
                ]);
            } else {
                Log::error('Failed to send SMS via Twilio', [
                    'phone' => $phone,
                    'status' => $response->status(),
                    'response' => $response->body(),
                ]);
            }
        } catch (\Exception $e) {
            Log::error('Exception sending SMS via Twilio', [
                'phone' => $phone,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Log SMS instead of sending (for development)
     */
    protected function sendViaLog(string $phone, string $message): void
    {
        Log::info('SMS notification (log only)', [
            'phone' => $phone,
            'message' => $message,
        ]);
    }
}
