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
        Schema::create('delivery_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('delivery_id')->constrained('deliveries')->onDelete('cascade');
            $table->enum('sender_type', ['courier', 'pharmacy', 'client']);
            $table->unsignedBigInteger('sender_id');
            $table->enum('receiver_type', ['courier', 'pharmacy', 'client']);
            $table->unsignedBigInteger('receiver_id');
            $table->text('message');
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
            
            // Index pour récupérer rapidement les messages d'une livraison
            $table->index(['delivery_id', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('delivery_messages');
    }
};
