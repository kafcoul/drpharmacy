<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\JekoPaymentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class JekoWebhookController extends Controller
{
    public function __construct(
        private JekoPaymentService $jekoService
    ) {}

    /**
     * Recevoir et traiter les webhooks JEKO
     * POST /api/webhooks/jeko
     * 
     * SECURITY V-007: Logs sécurisés - ne pas exposer données sensibles
     * SECURITY V-009: IP Whitelist - vérifier l'origine des webhooks
     */
    public function handle(Request $request): JsonResponse
    {
        // SECURITY V-009: Vérifier l'IP source du webhook
        if (!$this->isAllowedIp($request->ip())) {
            Log::warning('JEKO Webhook: IP non autorisée', [
                'ip' => $request->ip(),
                'user_agent' => $request->userAgent(),
            ]);
            
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized IP',
            ], 403);
        }

        // Récupérer la signature depuis l'en-tête (Jeko-Signature selon doc officielle)
        $signature = $request->header('Jeko-Signature', '');

        $payload = $request->all();

        // SECURITY V-007: Log minimal - pas de headers ni body complet
        Log::info('JEKO Webhook: Requête reçue', [
            'reference' => $payload['reference'] ?? 'unknown',
            'status' => $payload['status'] ?? 'unknown',
            'ip' => $request->ip(),
            'has_signature' => !empty($signature),
        ]);

        // Valider et traiter le webhook
        try {
            $processed = $this->jekoService->handleWebhook($payload, $signature);

            if (!$processed) {
                Log::warning('JEKO Webhook: Non traité', [
                    'reference' => $payload['reference'] ?? 'unknown',
                    'reason' => 'validation_failed',
                ]);

                return response()->json([
                    'status' => 'error',
                    'message' => 'Webhook not processed',
                ], 400);
            }

            Log::info('JEKO Webhook: Traité avec succès', [
                'reference' => $payload['reference'] ?? 'unknown',
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Webhook processed',
            ]);

        } catch (\Exception $e) {
            // SECURITY V-007: Ne pas logger le stack trace complet en production
            Log::error('JEKO Webhook: Erreur de traitement', [
                'reference' => $payload['reference'] ?? 'unknown',
                'error' => $e->getMessage(),
                // Stack trace uniquement en dev
                'trace' => app()->environment('local') ? $e->getTraceAsString() : null,
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Internal processing error',
            ], 500);
        }
    }

    /**
     * Endpoint de santé pour vérifier que le webhook est accessible
     * GET /api/webhooks/jeko/health
     */
    public function health(): JsonResponse
    {
        return response()->json([
            'status' => 'ok',
            'service' => 'jeko-webhook',
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    /**
     * SECURITY V-009: Vérifier si l'IP est autorisée pour les webhooks
     * 
     * @param string|null $ip
     * @return bool
     */
    private function isAllowedIp(?string $ip): bool
    {
        $allowedIps = config('services.jeko.webhook_allowed_ips', []);
        
        // SECURITY: En production, REJETER si aucune IP configurée
        if (empty($allowedIps)) {
            if (app()->isProduction()) {
                Log::critical('JEKO Webhook: JEKO_WEBHOOK_IPS non configuré en PRODUCTION - Toutes les requêtes webhook sont REJETÉES', [
                    'ip' => $ip,
                    'environment' => app()->environment(),
                ]);
                return false;
            }
            
            // En dev/staging, autoriser tout avec warning
            Log::warning('JEKO Webhook: Aucune IP whitelist configurée (JEKO_WEBHOOK_IPS) - Mode développement', [
                'ip' => $ip,
            ]);
            return true;
        }

        // Vérifier si l'IP est dans la liste blanche
        return in_array($ip, $allowedIps, true);
    }
}
