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
        // La table existe déjà, on ajoute seulement les colonnes manquantes
        if (Schema::hasTable('support_tickets')) {
            Schema::table('support_tickets', function (Blueprint $table) {
                if (!Schema::hasColumn('support_tickets', 'reference')) {
                    $table->string('reference')->nullable()->unique()->after('status');
                }
                if (!Schema::hasColumn('support_tickets', 'resolved_at')) {
                    $table->timestamp('resolved_at')->nullable()->after('reference');
                }
            });
        } else {
            Schema::create('support_tickets', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->string('subject');
                $table->text('description');
                $table->enum('category', ['order', 'delivery', 'payment', 'account', 'app_bug', 'other'])->default('other');
                $table->enum('priority', ['low', 'medium', 'high'])->default('medium');
                $table->enum('status', ['open', 'in_progress', 'resolved', 'closed'])->default('open');
                $table->string('reference')->unique();
                $table->timestamp('resolved_at')->nullable();
                $table->timestamps();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('support_tickets');
    }
};
