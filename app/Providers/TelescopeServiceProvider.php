<?php

namespace App\Providers;

use Illuminate\Support\Facades\Gate;
use Laravel\Telescope\IncomingEntry;
use Laravel\Telescope\Telescope;
use Laravel\Telescope\TelescopeApplicationServiceProvider;

class TelescopeServiceProvider extends TelescopeApplicationServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Activer le mode nuit (dark mode) pour Telescope
        Telescope::night();

        $this->hideSensitiveRequestDetails();

        $isLocal = $this->app->environment('local');

        // En local, tout enregistrer. En prod, uniquement les erreurs/échecs
        Telescope::filter(function (IncomingEntry $entry) use ($isLocal) {
            if ($isLocal) {
                return true;
            }

            return $entry->isReportableException() ||
                   $entry->isFailedRequest() ||
                   $entry->isFailedJob() ||
                   $entry->isScheduledTask() ||
                   $entry->hasMonitoredTag();
        });

        // Tags personnalisés pour faciliter le filtrage
        Telescope::tag(function (IncomingEntry $entry) {
            if ($entry->type === 'request') {
                // Taguer les requêtes API
                if (str_starts_with($entry->content['uri'] ?? '', '/api/')) {
                    return ['api'];
                }
            }
            return [];
        });
    }

    /**
     * Prevent sensitive request details from being logged by Telescope.
     */
    protected function hideSensitiveRequestDetails(): void
    {
        if ($this->app->environment('local')) {
            return;
        }

        // Masquer les mots de passe et tokens sensibles
        Telescope::hideRequestParameters([
            '_token',
            'password',
            'password_confirmation',
            'current_password',
            'new_password',
        ]);

        Telescope::hideRequestHeaders([
            'cookie',
            'x-csrf-token',
            'x-xsrf-token',
            'authorization',
        ]);
    }

    /**
     * Register the Telescope gate.
     *
     * This gate determines who can access Telescope in non-local environments.
     */
    protected function gate(): void
    {
        Gate::define('viewTelescope', function ($user) {
            // Liste des emails autorisés à accéder à Telescope en production
            return in_array($user->email, [
                'admin@drpharma.ci',
                'dev@drpharma.ci',
                // Ajouter d'autres emails administrateurs ici
            ]);
        });
    }
}
