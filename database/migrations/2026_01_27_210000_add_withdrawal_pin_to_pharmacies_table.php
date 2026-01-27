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
            // PIN de sécurité pour les opérations financières (hashé)
            $table->string('withdrawal_pin')->nullable()->after('auto_withdraw_enabled');
            $table->timestamp('pin_set_at')->nullable()->after('withdrawal_pin');
            $table->unsignedTinyInteger('pin_attempts')->default(0)->after('pin_set_at');
            $table->timestamp('pin_locked_until')->nullable()->after('pin_attempts');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('pharmacies', function (Blueprint $table) {
            $table->dropColumn(['withdrawal_pin', 'pin_set_at', 'pin_attempts', 'pin_locked_until']);
        });
    }
};
