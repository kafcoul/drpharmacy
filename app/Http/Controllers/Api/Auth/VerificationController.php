<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\OtpService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class VerificationController extends Controller
{
    protected $otpService;

    public function __construct(OtpService $otpService)
    {
        $this->otpService = $otpService;
    }

    /**
     * Verify Account OTP
     */
    public function verify(Request $request)
    {
        $request->validate([
            'identifier' => 'required|string', // email or phone
            'otp' => 'required|string|size:4',
        ]);

        $identifier = $request->identifier;
        
        if ($this->otpService->verifyOtp($identifier, $request->otp)) {
            // Find user and mark as verified
            $user = User::where('email', $identifier)
                ->orWhere('phone', $identifier)
                ->first();

            if ($user) {
                if (!$user->phone_verified_at) {
                    $user->phone_verified_at = now();
                    $user->save();
                }
                
                // Generate token for auto-login
                $token = $user->createToken('auth_token')->plainTextToken;

                return response()->json([
                    'message' => 'Compte vérifié avec succès',
                    'user' => $user,
                    'token' => $token,
                ]);
            }
            
            return response()->json(['message' => 'Utilisateur non trouvé'], 404);
        }

        return response()->json(['message' => 'Code OTP invalide ou expiré'], 400);
    }

    /**
     * Resend OTP
     */
    public function resend(Request $request)
    {
        $request->validate([
            'identifier' => 'required|string',
        ]);

        $identifier = $request->identifier;
        
        // Check if user exists
        $user = User::where('email', $identifier)
            ->orWhere('phone', $identifier)
            ->first();

        if (!$user) {
            return response()->json(['message' => 'Utilisateur non trouvé'], 404);
        }

        $otp = $this->otpService->generateOtp($identifier);
        
        // Send OTP with email as fallback if identifier is phone
        $fallbackEmail = filter_var($identifier, FILTER_VALIDATE_EMAIL) ? null : $user->email;
        $channel = $this->otpService->sendOtp($identifier, $otp, 'verification', $fallbackEmail);

        // Determine message based on channel used
        $message = match($channel) {
            'email' => 'Code envoyé par email',
            'sms' => 'Code envoyé par SMS',
            'sms_fallback_email' => 'SMS indisponible, code envoyé par email à ' . $this->maskEmail($user->email),
            default => 'Nouveau code envoyé',
        };

        return response()->json([
            'message' => $message,
            'channel' => $channel,
        ]);
    }

    /**
     * Verify phone via Firebase Authentication
     * Called after Firebase Phone Auth verification on mobile
     */
    public function verifyWithFirebase(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'firebase_uid' => 'required|string',
        ]);

        $phone = $request->phone;
        $firebaseUid = $request->firebase_uid;

        // Find user by phone number
        $user = User::where('phone', $phone)->first();

        if (!$user) {
            return response()->json(['message' => 'Utilisateur non trouvé'], 404);
        }

        // Store Firebase UID for future use (optional - for Firebase integration)
        if (!$user->firebase_uid) {
            $user->firebase_uid = $firebaseUid;
        }

        // Mark phone as verified
        if (!$user->phone_verified_at) {
            $user->phone_verified_at = now();
        }
        
        $user->save();

        // Generate token for auto-login
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Compte vérifié avec succès via Firebase',
            'user' => $user,
            'token' => $token,
        ]);
    }

    /**
     * Mask email for privacy (show first 2 chars and domain)
     */
    private function maskEmail(string $email): string
    {
        $parts = explode('@', $email);
        if (count($parts) !== 2) return '***@***';
        
        $name = $parts[0];
        $domain = $parts[1];
        
        $maskedName = substr($name, 0, 2) . str_repeat('*', max(0, strlen($name) - 2));
        return $maskedName . '@' . $domain;
    }
}
