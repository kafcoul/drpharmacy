<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     * 
     * Ajoute la colonne is_active à la table pharmacies pour compatibilité
     * avec le code existant (tests, factories, etc.)
     */
    public function up(): void
    {
        Schema::table('pharmacies', function (Blueprint $table) {
            $table->boolean('is_active')->default(true)->after('status');
        });

        // Synchroniser is_active avec le status existant
        // Les pharmacies approuvées sont actives
        DB::table('pharmacies')
            ->where('status', 'approved')
            ->update(['is_active' => true]);

        DB::table('pharmacies')
            ->where('status', '!=', 'approved')
            ->update(['is_active' => false]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('pharmacies', function (Blueprint $table) {
            $table->dropColumn('is_active');
        });
    }
};
