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
        Schema::table('couriers', function (Blueprint $table) {
            // KYC Documents
            $table->string('id_card_document')->nullable()->after('license_number');
            $table->string('selfie_document')->nullable()->after('id_card_document');
            
            // KYC Status
            $table->enum('kyc_status', ['incomplete', 'pending_review', 'approved', 'rejected'])
                ->default('incomplete')
                ->after('selfie_document');
            $table->text('kyc_rejection_reason')->nullable()->after('kyc_status');
            $table->timestamp('kyc_verified_at')->nullable()->after('kyc_rejection_reason');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('couriers', function (Blueprint $table) {
            $table->dropColumn([
                'id_card_document',
                'selfie_document',
                'kyc_status',
                'kyc_rejection_reason',
                'kyc_verified_at',
            ]);
        });
    }
};
