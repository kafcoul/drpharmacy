<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // R-003: CSP headers pour les routes web (Filament admin)
        $middleware->web(append: [
            \App\Http\Middleware\ContentSecurityPolicy::class,
        ]);
        
        $middleware->api(prepend: [
            \Illuminate\Http\Middleware\HandleCors::class,
            \App\Http\Middleware\EnsureProductionSafe::class, // SECURITY: Vérifier config production
        ]);
        
        // Enregistrer les alias de middleware personnalisés
        $middleware->alias([
            'role' => \App\Http\Middleware\CheckRole::class,
            'admin' => \App\Http\Middleware\EnsureUserIsAdmin::class,
            'production.safe' => \App\Http\Middleware\EnsureProductionSafe::class,
            'verified.phone' => \App\Http\Middleware\EnsurePhoneIsVerified::class,
            'csp' => \App\Http\Middleware\ContentSecurityPolicy::class, // R-003
            'courier' => \App\Http\Middleware\EnsureCourierProfile::class, // Vérifier profil coursier
        ]);
        
        // Appliquer le rate limiting par défaut sur l'API
        $middleware->api(append: [
            \Illuminate\Routing\Middleware\ThrottleRequests::class.':api',
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
