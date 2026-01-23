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
        Schema::table('prescriptions', function (Blueprint $table) {
            $table->decimal('quote_amount', 10, 2)->nullable()->after('status');
            $table->text('pharmacy_notes')->nullable()->after('quote_amount');
            // 'validated_by' already exists and will serve as the pharmacy ID who took it
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('prescriptions', function (Blueprint $table) {
            $table->dropColumn(['quote_amount', 'pharmacy_notes']);
        });
    }
};
