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
        Schema::create('wallets', function (Blueprint $table) {
            $table->id();
            $table->string('walletable_type'); // 'platform', 'App\Models\Pharmacy', 'App\Models\Courier'
            $table->unsignedBigInteger('walletable_id')->nullable(); // null pour platform
            $table->decimal('balance', 12, 2)->default(0);
            $table->string('currency', 3)->default('XOF');
            $table->timestamps();

            $table->unique(['walletable_type', 'walletable_id']);
            $table->index(['walletable_type', 'walletable_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('wallets');
    }
};
