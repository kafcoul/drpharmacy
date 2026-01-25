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
        Schema::table('duty_zones', function (Blueprint $table) {
            $table->decimal('latitude', 10, 7)->nullable()->after('description');
            $table->decimal('longitude', 10, 7)->nullable()->after('latitude');
            $table->decimal('radius', 5, 2)->default(10)->after('longitude'); // Default 10km radius
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('duty_zones', function (Blueprint $table) {
            $table->dropColumn(['latitude', 'longitude', 'radius']);
        });
    }
};
