<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Middleware pour s'assurer que le numéro de téléphone de l'utilisateur est vérifié.
 * 
 * Usage: Route::middleware('verified.phone')
 */
class EnsurePhoneIsVerified
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Non authentifié',
            ], 401);
        }

        // Vérifier si le téléphone est vérifié
        if (is_null($user->phone_verified_at)) {
            return response()->json([
                'success' => false,
                'message' => 'Veuillez d\'abord vérifier votre numéro de téléphone',
                'error_code' => 'PHONE_NOT_VERIFIED',
                'requires_verification' => true,
            ], 403);
        }

        return $next($request);
    }
}
