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
        Schema::table('wallet_transactions', function (Blueprint $table) {
            // Catégorie de transaction pour filtrage
            $table->string('category')->nullable()->after('type'); // topup, commission, withdrawal, refund, bonus
            
            // Lien vers la livraison (pour traçabilité commission)
            $table->foreignId('delivery_id')->nullable()->after('description')->constrained()->nullOnDelete();
            
            // Méthode de paiement utilisée (pour recharges)
            $table->string('payment_method')->nullable()->after('delivery_id'); // orange_money, mtn_momo, wave, card
            
            // Statut de la transaction
            $table->string('status')->default('completed')->after('metadata'); // pending, completed, failed, cancelled
            
            // Index pour performance
            $table->index('category');
            $table->index('status');
            $table->index('delivery_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('wallet_transactions', function (Blueprint $table) {
            $table->dropForeign(['delivery_id']);
            $table->dropColumn(['category', 'delivery_id', 'payment_method', 'status']);
        });
    }
};
