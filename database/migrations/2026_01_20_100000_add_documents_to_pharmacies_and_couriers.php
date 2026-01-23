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
        Schema::table('pharmacies', function (Blueprint $table) {
            $table->string('license_document')->nullable()->after('license_number');
        });

        Schema::table('couriers', function (Blueprint $table) {
            $table->string('driving_license_document')->nullable()->after('license_number');
            $table->string('vehicle_registration_document')->nullable()->after('driving_license_document');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('pharmacies', function (Blueprint $table) {
            $table->dropColumn('license_document');
        });

        Schema::table('couriers', function (Blueprint $table) {
            $table->dropColumn(['driving_license_document', 'vehicle_registration_document']);
        });
    }
};
