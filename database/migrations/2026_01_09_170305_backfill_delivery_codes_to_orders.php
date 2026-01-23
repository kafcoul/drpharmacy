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
        // Get all orders where delivery_code is null
        $orders = \App\Models\Order::whereNull('delivery_code')->get();
        
        foreach ($orders as $order) {
            $order->delivery_code = str_pad(mt_rand(0, 9999), 4, '0', STR_PAD_LEFT);
            $order->save();
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // No need to reverse as this is data fix
    }
};
