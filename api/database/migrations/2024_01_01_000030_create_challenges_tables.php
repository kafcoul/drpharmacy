<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('challenges', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->enum('type', ['daily', 'weekly', 'monthly', 'one_time', 'milestone']);
            $table->enum('metric', ['deliveries_count', 'earnings_amount', 'consecutive_days', 'rating_average', 'distance_km']);
            $table->integer('target_value');
            $table->integer('reward_amount');
            $table->string('icon')->default('star');
            $table->string('color')->default('amber');
            $table->boolean('is_active')->default(true);
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('ends_at')->nullable();
            $table->timestamps();
        });

        Schema::create('courier_challenges', function (Blueprint $table) {
            $table->id();
            $table->foreignId('courier_id')->constrained()->cascadeOnDelete();
            $table->foreignId('challenge_id')->constrained()->cascadeOnDelete();
            $table->integer('current_progress')->default(0);
            $table->enum('status', ['in_progress', 'completed', 'rewarded', 'expired'])->default('in_progress');
            $table->timestamp('started_at');
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('rewarded_at')->nullable();
            $table->timestamps();

            $table->unique(['courier_id', 'challenge_id', 'started_at'], 'courier_challenge_period_unique');
        });

        Schema::create('bonus_multipliers', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description');
            $table->enum('type', ['time_based', 'zone_based', 'weather', 'special_event']);
            $table->decimal('multiplier', 5, 2)->default(1);
            $table->integer('flat_bonus')->default(0);
            $table->json('conditions')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('ends_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bonus_multipliers');
        Schema::dropIfExists('courier_challenges');
        Schema::dropIfExists('challenges');
    }
};
