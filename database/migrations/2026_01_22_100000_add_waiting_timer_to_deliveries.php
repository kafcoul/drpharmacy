<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * 
     * Ajoute les champs pour la gestion de la minuterie d'attente:
     * - waiting_started_at: timestamp quand le livreur signale qu'il attend le client
     * - waiting_fee: frais d'attente accumulés (100 FCFA/min)
     * - waiting_ended_at: timestamp quand l'attente se termine (livraison ou annulation)
     * - auto_cancelled_at: si la livraison a été annulée automatiquement par timeout
     */
    public function up(): void
    {
        Schema::table('deliveries', function (Blueprint $table) {
            $table->timestamp('waiting_started_at')->nullable()->after('delivered_at');
            $table->timestamp('waiting_ended_at')->nullable()->after('waiting_started_at');
            $table->integer('waiting_fee')->default(0)->after('waiting_ended_at'); // en FCFA
            $table->timestamp('auto_cancelled_at')->nullable()->after('waiting_fee');
            $table->string('cancellation_reason')->nullable()->after('auto_cancelled_at');
            
            // Index pour optimiser les requêtes de vérification des timeouts
            $table->index('waiting_started_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('deliveries', function (Blueprint $table) {
            $table->dropIndex(['waiting_started_at']);
            $table->dropColumn([
                'waiting_started_at',
                'waiting_ended_at',
                'waiting_fee',
                'auto_cancelled_at',
                'cancellation_reason',
            ]);
        });
    }
};
