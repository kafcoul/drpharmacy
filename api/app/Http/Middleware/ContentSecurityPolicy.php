<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * R-003: Content-Security-Policy Middleware
 * 
 * Ajoute des headers de sécurité CSP pour protéger contre XSS et autres attaques.
 * Activé uniquement pour les réponses HTML (interfaces web admin).
 */
class ContentSecurityPolicy
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        // N'appliquer CSP que pour les réponses HTML (Filament admin, etc.)
        if ($this->isHtmlResponse($response)) {
            $this->addSecurityHeaders($response);
        }

        return $response;
    }

    /**
     * Vérifier si la réponse est HTML
     */
    private function isHtmlResponse(Response $response): bool
    {
        $contentType = $response->headers->get('Content-Type', '');
        return str_contains($contentType, 'text/html');
    }

    /**
     * Ajouter les headers de sécurité
     */
    private function addSecurityHeaders(Response $response): void
    {
        // Content-Security-Policy
        // Configuration permissive pour Filament (nécessite inline scripts/styles)
        $csp = $this->buildCspPolicy();
        $response->headers->set('Content-Security-Policy', $csp);

        // Autres headers de sécurité recommandés
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('X-Frame-Options', 'SAMEORIGIN');
        $response->headers->set('X-XSS-Protection', '1; mode=block');
        $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
        
        // Permissions-Policy (anciennement Feature-Policy)
        $response->headers->set('Permissions-Policy', 'geolocation=(self), microphone=(), camera=()');
    }

    /**
     * Construire la politique CSP
     */
    private function buildCspPolicy(): string
    {
        $policies = [
            // Sources par défaut
            "default-src 'self'",
            
            // Scripts - 'unsafe-inline' nécessaire pour Filament/Alpine.js
            "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://unpkg.com",
            
            // Styles - 'unsafe-inline' nécessaire pour Tailwind CSS dynamique
            "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://fonts.bunny.net",
            
            // Polices
            "font-src 'self' https://fonts.gstatic.com https://fonts.bunny.net data:",
            
            // Images
            "img-src 'self' data: https: blob:",
            
            // Connexions (API, WebSockets)
            "connect-src 'self' https://api.jeko.ci https://api.jeko.africa wss:",
            
            // Frames
            "frame-src 'self'",
            
            // Objets (désactivé pour sécurité)
            "object-src 'none'",
            
            // Base URI
            "base-uri 'self'",
            
            // Form actions
            "form-action 'self'",
            
            // Frame ancestors (protection clickjacking)
            "frame-ancestors 'self'",
        ];

        return implode('; ', $policies);
    }
}
