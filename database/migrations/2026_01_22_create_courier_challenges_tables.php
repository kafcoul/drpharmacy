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
        // Table des challenges disponibles
        Schema::create('challenges', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->enum('type', ['daily', 'weekly', 'monthly', 'one_time', 'milestone']);
            $table->enum('metric', ['deliveries_count', 'earnings_amount', 'consecutive_days', 'rating_average', 'distance_km']);
            $table->integer('target_value'); // Ex: 10 livraisons, 5000 FCFA
            $table->integer('reward_amount'); // Bonus en FCFA
            $table->string('icon')->default('star'); // Nom de l'icône
            $table->string('color')->default('amber'); // Couleur du badge
            $table->boolean('is_active')->default(true);
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('ends_at')->nullable();
            $table->timestamps();
        });

        // Progression des couriers sur les challenges
        Schema::create('courier_challenges', function (Blueprint $table) {
            $table->id();
            $table->foreignId('courier_id')->constrained()->onDelete('cascade');
            $table->foreignId('challenge_id')->constrained()->onDelete('cascade');
            $table->integer('current_progress')->default(0);
            $table->enum('status', ['in_progress', 'completed', 'rewarded', 'expired'])->default('in_progress');
            $table->timestamp('started_at');
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('rewarded_at')->nullable();
            $table->timestamps();

            $table->unique(['courier_id', 'challenge_id', 'started_at'], 'courier_challenge_period_unique');
        });

        // Table des bonus ponctuels (heures de pointe, météo, etc.)
        Schema::create('bonus_multipliers', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description');
            $table->enum('type', ['time_based', 'zone_based', 'weather', 'special_event']);
            $table->decimal('multiplier', 3, 2)->default(1.00); // Ex: 1.50 = +50%
            $table->integer('flat_bonus')->default(0); // Bonus fixe ajouté
            $table->json('conditions')->nullable(); // Conditions JSON (heures, zones, etc.)
            $table->boolean('is_active')->default(true);
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('ends_at')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('courier_challenges');
        Schema::dropIfExists('challenges');
        Schema::dropIfExists('bonus_multipliers');
    }
};
