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
        Schema::table('deliveries', function (Blueprint $table) {
            $table->string('pickup_address')->nullable()->after('courier_id');
            $table->string('delivery_address')->nullable()->after('pickup_longitude');
            $table->decimal('delivery_latitude', 10, 7)->nullable()->after('delivery_address');
            $table->decimal('delivery_longitude', 10, 7)->nullable()->after('delivery_latitude');
            $table->decimal('delivery_fee', 10, 2)->default(0)->after('delivery_longitude');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('deliveries', function (Blueprint $table) {
            $table->dropColumn(['pickup_address', 'delivery_address', 'delivery_latitude', 'delivery_longitude', 'delivery_fee']);
        });
    }
};
