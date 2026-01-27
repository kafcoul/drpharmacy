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
        Schema::table('jeko_payments', function (Blueprint $table) {
            // Payout/Disbursement fields
            $table->boolean('is_payout')->default(false)->after('webhook_processed');
            $table->string('recipient_phone')->nullable()->after('is_payout');
            $table->json('bank_details')->nullable()->after('recipient_phone');
            $table->string('description')->nullable()->after('bank_details');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('jeko_payments', function (Blueprint $table) {
            $table->dropColumn(['is_payout', 'recipient_phone', 'bank_details', 'description']);
        });
    }
};
