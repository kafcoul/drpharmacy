<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class SmsService
{
    protected string $provider;
    
    public function __construct()
    {
        $this->provider = config('sms.default', 'africastalking');
    }

    /**
     * Send an SMS message
     */
    public function send(string $phone, string $message): bool
    {
        // Normaliser le numéro de téléphone
        $phone = $this->normalizePhone($phone);
        
        return match($this->provider) {
            'twilio' => $this->sendViaTwilio($phone, $message),
            'africastalking' => $this->sendViaAfricasTalking($phone, $message),
            'infobip' => $this->sendViaInfobip($phone, $message),
            default => $this->logOnly($phone, $message),
        };
    }

    /**
     * Send via Twilio
     */
    protected function sendViaTwilio(string $phone, string $message): bool
    {
        $accountSid = config('sms.twilio.sid');
        $authToken = config('sms.twilio.token');
        $fromNumber = config('sms.twilio.from');

        if (!$accountSid || !$authToken || !$fromNumber) {
            Log::warning('Twilio credentials not configured');
            return $this->logOnly($phone, $message);
        }

        try {
            $response = Http::withBasicAuth($accountSid, $authToken)
                ->asForm()
                ->post("https://api.twilio.com/2010-04-01/Accounts/{$accountSid}/Messages.json", [
                    'To' => $phone,
                    'From' => $fromNumber,
                    'Body' => $message,
                ]);

            if ($response->successful()) {
                Log::info('SMS sent via Twilio', ['phone' => $phone, 'sid' => $response->json('sid')]);
                return true;
            }

            Log::error('Twilio SMS failed', ['phone' => $phone, 'error' => $response->json()]);
            return false;

        } catch (\Exception $e) {
            Log::error('Twilio exception', ['phone' => $phone, 'error' => $e->getMessage()]);
            return false;
        }
    }

    /**
     * Send via Africa's Talking
     */
    protected function sendViaAfricasTalking(string $phone, string $message): bool
    {
        $apiKey = config('sms.africastalking.api_key');
        $username = config('sms.africastalking.username');
        $senderId = config('sms.africastalking.sender_id', 'DRPHARMA');

        if (!$apiKey || !$username) {
            Log::warning('Africa\'s Talking credentials not configured');
            return $this->logOnly($phone, $message);
        }

        try {
            $response = Http::withHeaders([
                'apiKey' => $apiKey,
                'Content-Type' => 'application/x-www-form-urlencoded',
                'Accept' => 'application/json',
            ])->asForm()->post('https://api.africastalking.com/version1/messaging', [
                'username' => $username,
                'to' => $phone,
                'message' => $message,
                'from' => $senderId,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $recipients = $data['SMSMessageData']['Recipients'] ?? [];
                
                if (!empty($recipients) && $recipients[0]['status'] === 'Success') {
                    Log::info('SMS sent via Africa\'s Talking', [
                        'phone' => $phone, 
                        'messageId' => $recipients[0]['messageId'] ?? null
                    ]);
                    return true;
                }
                
                Log::warning('Africa\'s Talking SMS status not Success', ['response' => $data]);
                return false;
            }

            Log::error('Africa\'s Talking SMS failed', ['phone' => $phone, 'error' => $response->body()]);
            return false;

        } catch (\Exception $e) {
            Log::error('Africa\'s Talking exception', ['phone' => $phone, 'error' => $e->getMessage()]);
            return false;
        }
    }

    /**
     * Send via Infobip
     */
    protected function sendViaInfobip(string $phone, string $message): bool
    {
        $apiKey = config('sms.infobip.api_key');
        $baseUrl = config('sms.infobip.base_url');
        $senderId = config('sms.infobip.sender', 'DRPHARMA');

        if (!$apiKey || !$baseUrl) {
            Log::warning('Infobip credentials not configured');
            return $this->logOnly($phone, $message);
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => "App {$apiKey}",
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
            ])->post("{$baseUrl}/sms/2/text/advanced", [
                'messages' => [
                    [
                        'destinations' => [['to' => $phone]],
                        'from' => $senderId,
                        'text' => $message,
                    ]
                ]
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $messages = $data['messages'] ?? [];
                
                if (!empty($messages)) {
                    Log::info('SMS sent via Infobip', [
                        'phone' => $phone, 
                        'messageId' => $messages[0]['messageId'] ?? null
                    ]);
                    return true;
                }
            }

            Log::error('Infobip SMS failed', ['phone' => $phone, 'error' => $response->body()]);
            return false;

        } catch (\Exception $e) {
            Log::error('Infobip exception', ['phone' => $phone, 'error' => $e->getMessage()]);
            return false;
        }
    }

    /**
     * Just log the message (for development)
     */
    protected function logOnly(string $phone, string $message): bool
    {
        Log::info('SMS (log only)', ['phone' => $phone, 'message' => $message]);
        return true;
    }

    /**
     * Normalize phone number to international format
     */
    protected function normalizePhone(string $phone): string
    {
        // Retirer les espaces et caractères spéciaux
        $phone = preg_replace('/[^\d+]/', '', $phone);
        
        $countryCode = config('sms.default_country_code', '+225');
        
        // Si commence par 0, c'est un numéro local
        if (str_starts_with($phone, '0')) {
            $phone = $countryCode . substr($phone, 1);
        }
        
        // Si pas de +, ajouter le code pays
        if (!str_starts_with($phone, '+')) {
            // Vérifier si c'est déjà un numéro international (commence par un indicatif)
            $codeWithoutPlus = ltrim($countryCode, '+');
            if (strlen($phone) === 10 && !str_starts_with($phone, $codeWithoutPlus)) {
                $phone = $countryCode . $phone;
            } elseif (!str_starts_with($phone, $codeWithoutPlus)) {
                $phone = '+' . $phone;
            } else {
                $phone = '+' . $phone;
            }
        }
        
        return $phone;
    }

    /**
     * Check balance (for Africa's Talking)
     */
    public function checkBalance(): ?array
    {
        if ($this->provider !== 'africastalking') {
            return null;
        }

        $apiKey = config('sms.africastalking.api_key');
        $username = config('sms.africastalking.username');

        try {
            $response = Http::withHeaders([
                'apiKey' => $apiKey,
                'Accept' => 'application/json',
            ])->get("https://api.africastalking.com/version1/user?username={$username}");

            if ($response->successful()) {
                return $response->json('UserData');
            }
        } catch (\Exception $e) {
            Log::error('Failed to check SMS balance', ['error' => $e->getMessage()]);
        }

        return null;
    }
}
