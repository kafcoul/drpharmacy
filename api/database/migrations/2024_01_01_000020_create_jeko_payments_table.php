<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('jeko_payments', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->string('reference')->unique();
            $table->string('jeko_payment_request_id')->nullable()->index();
            $table->morphs('payable');
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->integer('amount_cents');
            $table->string('currency')->default('XOF');
            $table->string('payment_method');
            $table->enum('status', ['pending', 'processing', 'success', 'failed', 'expired'])->default('pending');
            $table->text('redirect_url')->nullable();
            $table->text('success_url')->nullable();
            $table->text('error_url')->nullable();
            $table->json('transaction_data')->nullable();
            $table->text('error_message')->nullable();
            $table->timestamp('initiated_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('webhook_received_at')->nullable();
            $table->boolean('webhook_processed')->default(false);
            
            // Payout fields
            $table->boolean('is_payout')->default(false);
            $table->string('recipient_phone')->nullable();
            $table->json('bank_details')->nullable();
            $table->string('description')->nullable();
            
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('jeko_payments');
    }
};
