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
            $table->decimal('withdrawal_threshold', 12, 2)->default(50000)->after('is_featured');
            $table->boolean('auto_withdraw_enabled')->default(false)->after('withdrawal_threshold');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('pharmacies', function (Blueprint $table) {
            $table->dropColumn(['withdrawal_threshold', 'auto_withdraw_enabled']);
        });
    }
};
