<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pharmacy_on_calls', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pharmacy_id')->constrained()->cascadeOnDelete();
            $table->foreignId('duty_zone_id')->nullable()->constrained()->nullOnDelete();
            $table->datetime('start_at');
            $table->datetime('end_at');
            $table->string('type')->default('night');
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['start_at', 'end_at']);
            $table->index(['type', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pharmacy_on_calls');
    }
};
