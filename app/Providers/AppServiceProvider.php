<?php

namespace App\Providers;

use App\Models\Order;
use App\Models\Product;
use App\Observers\OrderObserver;
use App\Observers\ProductObserver;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use App\Events\PaymentConfirmed;
use App\Listeners\DistributeCommissions;
use Illuminate\Support\Facades\Event;
use Illuminate\Database\Eloquent\Model;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Charger Telescope uniquement en environnement local
        if ($this->app->environment('local')) {
            $this->app->register(\Laravel\Telescope\TelescopeServiceProvider::class);
            $this->app->register(TelescopeServiceProvider::class);
        }
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Security: Prevent lazy loading in development to catch N+1 queries
        Model::preventLazyLoading(!app()->isProduction());
        
        // Security: Prevent silently discarding attributes
        Model::preventSilentlyDiscardingAttributes(!app()->isProduction());
        
        // Register Observers
        Order::observe(OrderObserver::class);
        Product::observe(ProductObserver::class);

        // Register Event Listeners
        Event::listen(
            PaymentConfirmed::class,
            DistributeCommissions::class,
        );

        // Configure Rate Limiters
        $this->configureRateLimiting();
    }

    /**
     * Configure the rate limiters for the application.
     * 
     * Security Audit Week 3 - Rate Limiting granulaire
     */
    protected function configureRateLimiting(): void
    {
        // Default API rate limit (60 req/min pour utilisateurs authentifiés)
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip())
                ->response(function () {
                    return response()->json([
                        'success' => false,
                        'message' => 'Trop de requêtes. Veuillez réessayer dans quelques instants.',
                    ], 429);
                });
        });

        // Authentication endpoints - TRÈS STRICT (anti brute-force)
        RateLimiter::for('auth', function (Request $request) {
            return Limit::perMinute(5)->by($request->ip())
                ->response(function () {
                    return response()->json([
                        'success' => false,
                        'message' => 'Trop de tentatives de connexion. Veuillez réessayer dans 1 minute.',
                    ], 429);
                });
        });

        // OTP verification - TRÈS STRICT (anti brute-force OTP)
        RateLimiter::for('otp', function (Request $request) {
            return Limit::perMinute(3)->by($request->ip())
                ->response(function () {
                    return response()->json([
                        'success' => false,
                        'message' => 'Trop de tentatives de vérification OTP. Veuillez réessayer dans 1 minute.',
                    ], 429);
                });
        });

        // OTP sending - Limité pour éviter le spam SMS
        RateLimiter::for('otp-send', function (Request $request) {
            return Limit::perMinute(2)->by($request->ip())
                ->response(function () {
                    return response()->json([
                        'success' => false,
                        'message' => 'Trop de demandes d\'OTP. Veuillez attendre 1 minute.',
                    ], 429);
                });
        });

        // Password reset - Strict
        RateLimiter::for('password-reset', function (Request $request) {
            return Limit::perMinute(3)->by($request->ip())
                ->response(function () {
                    return response()->json([
                        'success' => false,
                        'message' => 'Trop de demandes de réinitialisation. Veuillez réessayer dans 1 minute.',
                    ], 429);
                });
        });

        // Payment endpoints - TRÈS STRICT (prévention fraude)
        RateLimiter::for('payment', function (Request $request) {
            return Limit::perMinute(10)->by($request->user()?->id ?: $request->ip())
                ->response(function () {
                    return response()->json([
                        'success' => false,
                        'message' => 'Trop de tentatives de paiement. Veuillez réessayer dans quelques instants.',
                    ], 429);
                });
        });

        // Order creation - Modéré
        RateLimiter::for('orders', function (Request $request) {
            return Limit::perMinute(10)->by($request->user()?->id ?: $request->ip())
                ->response(function () {
                    return response()->json([
                        'success' => false,
                        'message' => 'Trop de commandes créées. Veuillez réessayer dans quelques instants.',
                    ], 429);
                });
        });

        // Search endpoints - Plus permissif
        RateLimiter::for('search', function (Request $request) {
            return Limit::perMinute(30)->by($request->user()?->id ?: $request->ip())
                ->response(function () {
                    return response()->json([
                        'success' => false,
                        'message' => 'Trop de recherches. Veuillez réessayer dans quelques instants.',
                    ], 429);
                });
        });

        // Uploads (prescriptions, images) - Strict
        RateLimiter::for('uploads', function (Request $request) {
            return Limit::perMinute(5)->by($request->user()?->id ?: $request->ip())
                ->response(function () {
                    return response()->json([
                        'success' => false,
                        'message' => 'Trop de fichiers uploadés. Veuillez réessayer dans quelques instants.',
                    ], 429);
                });
        });

        // Webhook endpoints - Limité par IP source
        RateLimiter::for('webhook', function (Request $request) {
            return Limit::perMinute(100)->by($request->ip())
                ->response(function () {
                    return response()->json([
                        'success' => false,
                        'message' => 'Rate limit exceeded for webhooks.',
                    ], 429);
                });
        });

        // Courier location updates - Fréquent mais limité
        RateLimiter::for('location', function (Request $request) {
            return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip())
                ->response(function () {
                    return response()->json([
                        'success' => false,
                        'message' => 'Trop de mises à jour de position.',
                    ], 429);
                });
        });

        // Notifications - Limité
        RateLimiter::for('notifications', function (Request $request) {
            return Limit::perMinute(30)->by($request->user()?->id ?: $request->ip());
        });

        // Public endpoints (sans auth) - Plus strict
        RateLimiter::for('public', function (Request $request) {
            return Limit::perMinute(20)->by($request->ip())
                ->response(function () {
                    return response()->json([
                        'success' => false,
                        'message' => 'Trop de requêtes. Veuillez réessayer dans quelques instants.',
                    ], 429);
                });
        });
    }
}
