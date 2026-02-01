<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('prescriptions', function (Blueprint $table) {
            // Ajouter la colonne order_id nullable (une ordonnance peut exister sans commande)
            $table->foreignId('order_id')->nullable()->after('customer_id')
                ->constrained('orders')->nullOnDelete();
            
            // Ajouter un champ pour identifier la source de l'ordonnance
            $table->enum('source', ['upload', 'checkout'])->default('upload')->after('status');
            
            // Index pour améliorer les performances
            $table->index(['customer_id', 'order_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('prescriptions', function (Blueprint $table) {
            $table->dropForeign(['order_id']);
            $table->dropColumn(['order_id', 'source']);
            $table->dropIndex(['customer_id', 'order_id']);
        });
    }
};
