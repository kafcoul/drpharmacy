<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

/**
 * Middleware pour vérifier que l'environnement de production est correctement configuré.
 * 
 * Vérifie:
 * - APP_DEBUG=false en production
 * - APP_ENV=production
 * - Variables critiques configurées
 */
class EnsureProductionSafe
{
    /**
     * Variables d'environnement critiques qui doivent être définies en production.
     */
    private array $requiredProductionVars = [
        'JEKO_WEBHOOK_SECRET',
        'MAIL_MAILER',
    ];

    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Ne vérifier qu'en production
        if (!app()->isProduction()) {
            return $next($request);
        }

        // CRITIQUE: APP_DEBUG doit être désactivé en production
        if (config('app.debug') === true) {
            Log::critical('SECURITY ALERT: APP_DEBUG=true en PRODUCTION', [
                'ip' => $request->ip(),
                'url' => $request->fullUrl(),
            ]);
            
            // Option 1: Bloquer (recommandé)
            return response()->json([
                'success' => false,
                'message' => 'Configuration de sécurité invalide',
            ], 503);
            
            // Option 2: Désactiver dynamiquement (moins sûr)
            // config(['app.debug' => false]);
        }

        // Vérifier les variables critiques
        foreach ($this->requiredProductionVars as $var) {
            if (empty(env($var))) {
                Log::warning("Variable d'environnement manquante en production: {$var}");
            }
        }

        return $next($request);
    }
}
