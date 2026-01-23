<?php
require_once 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use App\Models\Courier;
use App\Models\Delivery;
use App\Models\Order;
use App\Models\Pharmacy;
use App\Models\Wallet;
use App\Services\WalletService;

// Check getCommissionAmount
echo "Commission Amount: " . WalletService::getCommissionAmount() . "\n";

// Get a courier
$courier = Courier::first();
if ($courier) {
    $walletService = new WalletService();
    $can = $walletService->canCompleteDelivery($courier);
    echo "Can complete delivery: " . ($can ? 'yes' : 'no') . "\n";
}
