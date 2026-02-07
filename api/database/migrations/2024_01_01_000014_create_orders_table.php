<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('reference')->unique()->index();
            $table->foreignId('pharmacy_id')->constrained()->cascadeOnDelete();
            $table->foreignId('customer_id')->constrained('users')->cascadeOnDelete();
            $table->enum('status', [
                'pending', 'confirmed', 'paid', 'preparing', 'ready', 
                'assigned', 'in_delivery', 'delivered', 'cancelled', 'refunded'
            ])->default('pending')->index();
            $table->enum('payment_mode', ['cash', 'mobile_money', 'card', 'direct', 'platform'])->default('platform');
            $table->decimal('subtotal', 12, 2);
            $table->decimal('delivery_fee', 12, 2)->default(0);
            $table->decimal('service_fee', 12, 2)->default(0);
            $table->decimal('payment_fee', 12, 2)->default(0);
            $table->decimal('total_amount', 12, 2);
            $table->string('currency')->default('XOF');
            $table->text('customer_notes')->nullable();
            $table->text('pharmacy_notes')->nullable();
            $table->string('prescription_image')->nullable();
            $table->string('delivery_address');
            $table->string('delivery_city')->nullable();
            $table->decimal('delivery_latitude', 10, 8)->nullable();
            $table->decimal('delivery_longitude', 11, 8)->nullable();
            $table->string('customer_phone');
            $table->string('delivery_code')->nullable();
            $table->string('payment_status')->default('pending');
            $table->timestamp('confirmed_at')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamp('delivered_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->text('cancellation_reason')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['pharmacy_id', 'status']);
            $table->index(['customer_id', 'status']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
