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
        Schema::create('commission_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('commission_id')->constrained()->cascadeOnDelete();
            $table->string('actor_type'); // 'platform', 'App\Models\Pharmacy', 'App\Models\Courier'
            $table->unsignedBigInteger('actor_id')->nullable(); // null pour platform
            $table->decimal('rate', 5, 4); // 0.1000 = 10%
            $table->decimal('amount', 10, 2);
            $table->timestamps();

            $table->index(['commission_id', 'actor_type']);
            $table->index(['actor_type', 'actor_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('commission_lines');
    }
};
