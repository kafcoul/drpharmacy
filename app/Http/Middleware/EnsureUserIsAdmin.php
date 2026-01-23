<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsAdmin
{
    /**
     * Handle an incoming request.
     * Seul l'administrateur peut accéder au panel Filament Admin.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user || !$user->isAdmin()) {
            // Déconnecter l'utilisateur s'il n'est pas admin
            auth()->logout();
            
            return redirect()->route('filament.admin.auth.login')
                ->with('error', 'Accès réservé aux administrateurs uniquement.');
        }

        return $next($request);
    }
}
