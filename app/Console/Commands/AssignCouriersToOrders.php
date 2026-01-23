<?php

namespace App\Console\Commands;

use App\Models\Order;
use App\Services\CourierAssignmentService;
use Illuminate\Console\Command;

class AssignCouriersToOrders extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'couriers:assign-orders
                            {--order= : ID de la commande spécifique à assigner}
                            {--force : Réassigner même si déjà assigné}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Assigner automatiquement les livreurs aux commandes prêtes';

    protected CourierAssignmentService $assignmentService;

    public function __construct(CourierAssignmentService $assignmentService)
    {
        parent::__construct();
        $this->assignmentService = $assignmentService;
    }

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $orderId = $this->option('order');
        $force = $this->option('force');

        if ($orderId) {
            return $this->assignSpecificOrder($orderId, $force);
        }

        return $this->assignReadyOrders($force);
    }

    /**
     * Assigner une commande spécifique
     */
    protected function assignSpecificOrder(int $orderId, bool $force): int
    {
        $order = Order::find($orderId);

        if (!$order) {
            $this->error("Commande #{$orderId} introuvable");
            return Command::FAILURE;
        }

        if ($order->delivery()->exists() && !$force) {
            $this->warn("Commande #{$order->reference} a déjà une livraison assignée");
            return Command::SUCCESS;
        }

        $this->info("Assignation du livreur pour commande #{$order->reference}...");

        $delivery = $this->assignmentService->assignCourier($order);

        if ($delivery) {
            $this->info("✓ Livreur #{$delivery->courier_id} assigné à la commande #{$order->reference}");
            return Command::SUCCESS;
        }

        $this->error("✗ Impossible d'assigner un livreur à la commande #{$order->reference}");
        return Command::FAILURE;
    }

    /**
     * Assigner tous les livreurs aux commandes prêtes
     */
    protected function assignReadyOrders(bool $force): int
    {
        $query = Order::whereIn('status', ['ready', 'paid'])
            ->whereDoesntHave('delivery');

        if ($force) {
            $query = Order::whereIn('status', ['ready', 'paid']);
        }

        $orders = $query->get();

        if ($orders->isEmpty()) {
            $this->info("Aucune commande à assigner");
            return Command::SUCCESS;
        }

        $this->info("Traitement de {$orders->count()} commande(s)...");

        $successCount = 0;
        $failureCount = 0;

        $progressBar = $this->output->createProgressBar($orders->count());
        $progressBar->start();

        foreach ($orders as $order) {
            $delivery = $this->assignmentService->assignCourier($order);

            if ($delivery) {
                $successCount++;
                $this->line("\n✓ Commande #{$order->reference} → Livreur #{$delivery->courier_id}");
            } else {
                $failureCount++;
                $this->line("\n✗ Commande #{$order->reference} : Aucun livreur disponible");
            }

            $progressBar->advance();
        }

        $progressBar->finish();
        $this->newLine(2);

        $this->info("Résultat:");
        $this->table(
            ['Statut', 'Nombre'],
            [
                ['Succès', $successCount],
                ['Échecs', $failureCount],
                ['Total', $orders->count()],
            ]
        );

        return $failureCount === 0 ? Command::SUCCESS : Command::FAILURE;
    }
}
