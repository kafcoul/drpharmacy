<?php

namespace App\Console\Commands;

use App\Services\AutoAssignmentService;
use Illuminate\Console\Command;

class AutoAssignDeliveries extends Command
{
    /**
     * The name and signature of the console command.
     */
    protected $signature = 'deliveries:auto-assign 
                            {--dry-run : Simuler sans assigner}';

    /**
     * The console command description.
     */
    protected $description = 'Assigner automatiquement les livraisons en attente aux livreurs disponibles';

    /**
     * Execute the console command.
     */
    public function handle(AutoAssignmentService $service): int
    {
        $this->info('🚀 Démarrage de l\'assignation automatique...');
        
        // Afficher les stats
        $stats = $service->getAvailableCouriersStats();
        $this->table(
            ['Statut', 'Nombre'],
            [
                ['🟢 Disponibles', $stats['available']],
                ['🟡 Occupés', $stats['busy']],
                ['⚫ Hors ligne', $stats['offline']],
                ['📍 Actifs récemment', $stats['recently_active']],
            ]
        );

        if ($stats['available'] === 0) {
            $this->warn('⚠️  Aucun livreur disponible. Abandon.');
            return self::SUCCESS;
        }

        if ($this->option('dry-run')) {
            $this->info('🧪 Mode simulation activé (dry-run)');
            
            $pendingCount = \App\Models\Delivery::where('status', 'pending')
                ->whereNull('courier_id')
                ->count();
            
            $this->info("📦 {$pendingCount} livraison(s) en attente seraient assignées.");
            return self::SUCCESS;
        }

        // Exécuter l'assignation
        $results = $service->assignAllPendingDeliveries();

        $this->newLine();
        $this->info('📊 Résultats:');
        $this->info("  ✅ Assignées: {$results['assigned']}");
        $this->info("  ❌ Échouées: {$results['failed']}");

        if (!empty($results['details'])) {
            $this->newLine();
            $this->info('📋 Détails:');
            
            foreach ($results['details'] as $detail) {
                if ($detail['status'] === 'assigned') {
                    $this->line("  ✓ Livraison #{$detail['delivery_id']} → {$detail['courier_name']}");
                } else {
                    $this->warn("  ✗ Livraison #{$detail['delivery_id']} → Aucun livreur");
                }
            }
        }

        return self::SUCCESS;
    }
}
