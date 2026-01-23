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
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->cascadeOnDelete();
            $table->enum('provider', ['cinetpay', 'jeko', 'cash']); 
            $table->string('reference')->unique();
            $table->string('provider_transaction_id')->nullable();
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3)->default('XOF');
            $table->enum('status', ['SUCCESS', 'FAILED'])->default('SUCCESS');
            $table->string('payment_method')->nullable(); // orange_money, mtn_money, moov_money, card, cash
            $table->timestamp('confirmed_at');
            $table->timestamps();

            $table->index(['order_id', 'status']);
            $table->index('reference');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
