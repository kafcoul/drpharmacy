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
        Schema::create('settings', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->text('value')->nullable();
            $table->string('type')->default('string'); // string, integer, boolean, json
            $table->timestamps();
        });
        
        // Seed default settings
        DB::table('settings')->insert([
            ['key' => 'search_radius_km', 'value' => '20', 'type' => 'integer', 'created_at' => now(), 'updated_at' => now()],
            ['key' => 'default_commission_rate', 'value' => '10', 'type' => 'integer', 'created_at' => now(), 'updated_at' => now()],
            ['key' => 'support_phone', 'value' => '+225 07 07 07 07 07', 'type' => 'string', 'created_at' => now(), 'updated_at' => now()],
            ['key' => 'support_email', 'value' => 'support@drpharma.com', 'type' => 'string', 'created_at' => now(), 'updated_at' => now()],
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('settings');
    }
};
