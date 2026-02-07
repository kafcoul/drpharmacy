<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('commissions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->cascadeOnDelete();
            $table->decimal('total_amount', 12, 2);
            $table->timestamp('calculated_at');
            $table->timestamps();

            $table->index('order_id');
        });

        Schema::create('commission_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('commission_id')->constrained()->cascadeOnDelete();
            $table->string('actor_type');
            $table->unsignedBigInteger('actor_id')->nullable();
            $table->decimal('rate', 5, 4);
            $table->decimal('amount', 12, 2);
            $table->timestamps();

            $table->index(['commission_id', 'actor_type']);
            $table->index(['actor_type', 'actor_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('commission_lines');
        Schema::dropIfExists('commissions');
    }
};
