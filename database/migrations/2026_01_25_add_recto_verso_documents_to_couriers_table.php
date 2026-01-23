<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations - Add recto/verso KYC document support.
     */
    public function up(): void
    {
        Schema::table('couriers', function (Blueprint $table) {
            // Rename existing document columns to front (recto)
            if (Schema::hasColumn('couriers', 'id_card_document')) {
                $table->renameColumn('id_card_document', 'id_card_front_document');
            }
            if (Schema::hasColumn('couriers', 'driving_license_document')) {
                $table->renameColumn('driving_license_document', 'driving_license_front_document');
            }
        });

        Schema::table('couriers', function (Blueprint $table) {
            // Add back (verso) document columns
            $table->string('id_card_back_document')->nullable()->after('id_card_front_document');
            $table->string('driving_license_back_document')->nullable()->after('driving_license_front_document');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('couriers', function (Blueprint $table) {
            // Drop verso columns
            $table->dropColumn([
                'id_card_back_document',
                'driving_license_back_document',
            ]);
        });

        Schema::table('couriers', function (Blueprint $table) {
            // Rename back to original names
            if (Schema::hasColumn('couriers', 'id_card_front_document')) {
                $table->renameColumn('id_card_front_document', 'id_card_document');
            }
            if (Schema::hasColumn('couriers', 'driving_license_front_document')) {
                $table->renameColumn('driving_license_front_document', 'driving_license_document');
            }
        });
    }
};
