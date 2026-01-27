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
        Schema::table('withdrawal_requests', function (Blueprint $table) {
            // Jeko integration fields
            $table->string('jeko_reference')->nullable()->after('reference');
            $table->unsignedBigInteger('jeko_payment_id')->nullable()->after('jeko_reference');
            $table->string('phone')->nullable()->after('payment_method');
            $table->json('bank_details')->nullable()->after('account_details');
            $table->timestamp('completed_at')->nullable()->after('processed_at');
            $table->text('error_message')->nullable()->after('admin_notes');

            // Index for faster lookups
            $table->index('jeko_reference');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('withdrawal_requests', function (Blueprint $table) {
            $table->dropIndex(['jeko_reference']);
            $table->dropIndex(['status']);
            $table->dropColumn([
                'jeko_reference',
                'jeko_payment_id',
                'phone',
                'bank_details',
                'completed_at',
                'error_message'
            ]);
        });
    }
};
