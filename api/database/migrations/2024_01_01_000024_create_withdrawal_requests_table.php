<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('withdrawal_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wallet_id')->constrained()->cascadeOnDelete();
            $table->foreignId('pharmacy_id')->constrained()->cascadeOnDelete();
            $table->decimal('amount', 12, 2);
            $table->enum('payment_method', ['bank', 'mobile_money']);
            $table->json('account_details')->nullable();
            $table->string('reference')->unique();
            $table->enum('status', ['pending', 'processing', 'completed', 'rejected'])->default('pending')->index();
            $table->timestamp('processed_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->text('admin_notes')->nullable();
            $table->text('error_message')->nullable();
            
            // JEKO integration
            $table->string('jeko_reference')->nullable()->index();
            $table->unsignedBigInteger('jeko_payment_id')->nullable();
            $table->string('phone')->nullable();
            $table->json('bank_details')->nullable();
            
            $table->timestamps();

            $table->index(['pharmacy_id', 'status']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('withdrawal_requests');
    }
};
