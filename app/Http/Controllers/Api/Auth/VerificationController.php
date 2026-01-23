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
        $this->otpService->sendOtp($identifier, $otp);

        return response()->json(['message' => 'Nouveau code envoyé']);
    }
}
