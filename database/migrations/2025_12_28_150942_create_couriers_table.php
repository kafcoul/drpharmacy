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
        Schema::create('couriers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('phone')->unique();
            $table->string('vehicle_type')->nullable(); // moto, voiture, vélo
            $table->string('vehicle_number')->nullable();
            $table->string('license_number')->nullable();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->enum('status', ['available', 'busy', 'offline', 'suspended', 'pending_approval'])->default('offline');
            $table->decimal('rating', 3, 2)->default(5.00);
            $table->integer('completed_deliveries')->default(0);
            $table->timestamp('last_location_update')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['status', 'latitude', 'longitude']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('couriers');
    }
};
