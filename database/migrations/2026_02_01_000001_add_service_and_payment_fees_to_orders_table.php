<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * 
     * Ajoute les champs service_fee et payment_fee à la table orders.
     * Ces frais sont ajoutés au prix pour que la pharmacie reçoive le prix exact des médicaments.
     */
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            // Frais de service de la plateforme (pourcentage sur le subtotal)
            $table->decimal('service_fee', 10, 2)->default(0)->after('delivery_fee')
                ->comment('Frais de service plateforme en FCFA');
            
            // Frais de traitement paiement (pour paiement en ligne uniquement)
            $table->decimal('payment_fee', 10, 2)->default(0)->after('service_fee')
                ->comment('Frais de traitement paiement en ligne en FCFA');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn(['service_fee', 'payment_fee']);
        });
    }
};
