<?php

namespace App\Services;

use App\Mail\OtpMail;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class OtpService
{
    /**
     * Generate an OTP for a given identifier (email or phone)
     */
    public function generateOtp(string $identifier, int $length = 4, int $validityMinutes = 10): string
    {
        // In production, generate random number. For dev/demo, use '1234' or similar if needed, 
        // but let's stick to random for "complete backend".
        $otp = (string) random_int(pow(10, $length - 1), pow(10, $length) - 1);
        
        // Store in cache
        Cache::put('otp_' . $identifier, $otp, now()->addMinutes($validityMinutes));
        
        return $otp;
    }

    /**
     * Verify the OTP for a given identifier (and remove it)
     */
    public function verifyOtp(string $identifier, string $otp): bool
    {
        $cachedOtp = Cache::get('otp_' . $identifier);
        
        if ($cachedOtp && $cachedOtp === $otp) {
            // OTP is valid, remove it to prevent reuse
            Cache::forget('otp_' . $identifier);
            return true;
        }
        
        return false;
    }

    /**
     * Check if OTP is valid without removing it
     */
    public function checkOtp(string $identifier, string $otp): bool
    {
        $cachedOtp = Cache::get('otp_' . $identifier);
        return $cachedOtp && $cachedOtp === $otp;
    }

    /**
     * Send the OTP via appropriate channel
     */
    public function sendOtp(string $identifier, string $otp, string $purpose = 'verification'): void
    {
        // Determine if identifier is email or phone
        if (filter_var($identifier, FILTER_VALIDATE_EMAIL)) {
            $this->sendEmailOtp($identifier, $otp, $purpose);
        } else {
            $this->sendSmsOtp($identifier, $otp, $purpose);
        }
    }

    /**
     * Send OTP via email using Resend
     */
    protected function sendEmailOtp(string $email, string $otp, string $purpose = 'verification'): void
    {
        try {
            Mail::to($email)->send(new OtpMail($otp, $purpose));
            Log::info("OTP email sent successfully to {$email}");
        } catch (\Exception $e) {
            Log::error("Failed to send OTP email to {$email}: " . $e->getMessage());
            // En dev, on log quand même le code pour le debug
            Log::info("OTP for {$email}: {$otp}");
        }
    }

    /**
     * Send OTP via SMS
     */
    protected function sendSmsOtp(string $phone, string $otp, string $purpose = 'verification'): void
    {
        $message = $this->getSmsMessage($otp, $purpose);
        
        try {
            // Utiliser le SmsChannel existant via notification ou direct
            $smsService = app(SmsService::class);
            $smsService->send($phone, $message);
            Log::info("OTP SMS sent successfully to {$phone}");
        } catch (\Exception $e) {
            Log::error("Failed to send OTP SMS to {$phone}: " . $e->getMessage());
            // Fallback: log pour dev
            Log::info("OTP for {$phone}: {$otp}");
        }
    }

    /**
     * Get SMS message based on purpose
     */
    protected function getSmsMessage(string $otp, string $purpose): string
    {
        return match($purpose) {
            'verification' => "DR-PHARMA: Votre code de vérification est {$otp}. Valide 10 min.",
            'password_reset' => "DR-PHARMA: Code de réinitialisation: {$otp}. Valide 10 min.",
            'login' => "DR-PHARMA: Votre code de connexion est {$otp}. Valide 10 min.",
            default => "DR-PHARMA: Votre code est {$otp}. Valide 10 min.",
        };
    }
}
