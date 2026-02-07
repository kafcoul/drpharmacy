<?php

namespace App\Http\Middleware;

use App\Models\Courier;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class EnsureCourierProfile
{
    /**
     * Handle an incoming request.
     * Vérifie que l'utilisateur authentifié a un profil coursier valide.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = Auth::user();
        
        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'Non authentifié',
                'error_code' => 'UNAUTHENTICATED'
            ], 401);
        }
        
        $courier = Courier::where('user_id', $user->id)->first();
        
        if (!$courier) {
            return response()->json([
                'status' => 'error',
                'message' => 'Profil coursier non trouvé. Veuillez vous connecter avec un compte livreur.',
                'error_code' => 'COURIER_PROFILE_NOT_FOUND',
                'details' => [
                    'user_role' => $user->role ?? 'unknown',
                    'expected_role' => 'courier',
                    'solution' => 'Connectez-vous avec un compte coursier ou inscrivez-vous en tant que livreur.'
                ]
            ], 403);
        }
        
        // Vérifier si le coursier est approuvé
        if ($courier->status === 'pending') {
            return response()->json([
                'status' => 'error',
                'message' => 'Votre compte coursier est en attente d\'approbation.',
                'error_code' => 'COURIER_PENDING_APPROVAL',
                'details' => [
                    'status' => 'pending',
                    'solution' => 'Veuillez patienter, votre compte est en cours de vérification.'
                ]
            ], 403);
        }
        
        if ($courier->status === 'rejected' || $courier->status === 'suspended') {
            return response()->json([
                'status' => 'error',
                'message' => 'Votre compte coursier a été ' . ($courier->status === 'rejected' ? 'rejeté' : 'suspendu') . '.',
                'error_code' => 'COURIER_' . strtoupper($courier->status),
                'details' => [
                    'status' => $courier->status,
                    'solution' => 'Contactez le support pour plus d\'informations.'
                ]
            ], 403);
        }
        
        // Ajouter le courier à la requête pour éviter de le recharger dans le controller
        $request->merge(['courier' => $courier]);
        
        return $next($request);
    }
}
