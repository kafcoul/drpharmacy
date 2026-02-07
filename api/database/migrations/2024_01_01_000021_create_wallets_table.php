<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wallets', function (Blueprint $table) {
            $table->id();
            $table->string('walletable_type');
            $table->unsignedBigInteger('walletable_id')->nullable();
            $table->decimal('balance', 12, 2)->default(0);
            $table->string('currency')->default('XOF');
            $table->timestamps();

            $table->unique(['walletable_type', 'walletable_id']);
            $table->index(['walletable_type', 'walletable_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallets');
    }
};
