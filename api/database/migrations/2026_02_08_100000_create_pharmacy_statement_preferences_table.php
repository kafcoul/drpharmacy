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
        Schema::create('pharmacy_statement_preferences', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pharmacy_id')->constrained()->onDelete('cascade');
            $table->enum('frequency', ['weekly', 'monthly', 'quarterly'])->default('monthly');
            $table->enum('format', ['pdf', 'excel', 'csv'])->default('pdf');
            $table->boolean('auto_send')->default(true);
            $table->string('email')->nullable(); // Email alternatif, sinon utilise celui de la pharmacie
            $table->timestamp('next_send_at')->nullable();
            $table->timestamp('last_sent_at')->nullable();
            $table->timestamps();

            $table->unique('pharmacy_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pharmacy_statement_preferences');
    }
};
