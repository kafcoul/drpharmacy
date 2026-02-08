<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Http\Request;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     * Pour les requêtes API, on retourne null pour éviter la redirection
     * et déclencher une réponse JSON 401.
     */
    protected function redirectTo(Request $request): ?string
    {
        // Pour les requêtes API ou attendant du JSON, ne pas rediriger
        if ($request->is('api/*') || $request->expectsJson()) {
            return null;
        }

        // Pour les autres requêtes web, rediriger vers Filament login (chemin direct, pas de route nommée)
        return '/finance/login';
    }
}
