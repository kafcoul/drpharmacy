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
        Schema::create('jeko_payments', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            
            // Référence unique interne
            $table->string('reference', 100)->unique();
            
            // ID de la demande de paiement JEKO
            $table->string('jeko_payment_request_id')->nullable()->index();
            
            // Relation polymorphique (Order, WalletTopup, etc.)
            $table->string('payable_type');
            $table->unsignedBigInteger('payable_id');
            $table->index(['payable_type', 'payable_id']);
            
            // Utilisateur qui a initié le paiement
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            
            // Montant en centimes et devise
            $table->unsignedBigInteger('amount_cents');
            $table->string('currency', 3)->default('XOF');
            
            // Méthode de paiement: wave, orange, mtn, moov, djamo
            $table->string('payment_method', 20);
            
            // Statut: pending, processing, success, failed, expired
            $table->enum('status', ['pending', 'processing', 'success', 'failed', 'expired'])->default('pending');
            
            // URL de redirection JEKO
            $table->text('redirect_url')->nullable();
            
            // URLs de callback
            $table->text('success_url')->nullable();
            $table->text('error_url')->nullable();
            
            // Données de la transaction JEKO (JSON)
            $table->json('transaction_data')->nullable();
            
            // Message d'erreur si échec
            $table->text('error_message')->nullable();
            
            // Timestamps de traitement
            $table->timestamp('initiated_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('webhook_received_at')->nullable();
            
            // Idempotency: éviter le double traitement webhook
            $table->boolean('webhook_processed')->default(false);
            
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('jeko_payments');
    }
};
