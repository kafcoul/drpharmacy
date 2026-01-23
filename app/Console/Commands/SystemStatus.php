<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Models\Product;
use App\Models\Order;
use App\Models\Pharmacy;
use App\Models\Courier;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class SystemStatus extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'drpharma:status';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Display DR-PHARMA system status and statistics';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $this->info('');
        $this->info('╔═══════════════════════════════════════════════════╗');
        $this->info('║         DR-PHARMA System Status Report           ║');
        $this->info('╚═══════════════════════════════════════════════════╝');
        $this->newLine();

        // Environment
        $this->components->twoColumnDetail('Environment', config('app.env'));
        $this->components->twoColumnDetail('Debug Mode', config('app.debug') ? '<fg=yellow>ON (Disable in production!)</>' : '<fg=green>OFF</>');
        $this->components->twoColumnDetail('Cache Driver', config('cache.default'));
        $this->components->twoColumnDetail('Database', config('database.default'));
        $this->newLine();

        // Statistics
        $this->info('📊 Database Statistics');
        $this->components->twoColumnDetail('Users', User::count());
        $this->components->twoColumnDetail('├─ Customers', User::where('role', 'customer')->count());
        $this->components->twoColumnDetail('├─ Pharmacies', User::where('role', 'pharmacy')->count());
        $this->components->twoColumnDetail('├─ Couriers', User::where('role', 'courier')->count());
        $this->components->twoColumnDetail('└─ Admins', User::where('role', 'admin')->count());
        $this->newLine();

        $this->components->twoColumnDetail('Pharmacies', Pharmacy::count());
        $this->components->twoColumnDetail('├─ Approved', Pharmacy::where('status', 'approved')->count());
        $this->components->twoColumnDetail('├─ Pending', Pharmacy::where('status', 'pending')->count());
        $this->components->twoColumnDetail('└─ Suspended', Pharmacy::where('status', 'suspended')->count());
        $this->newLine();

        $this->components->twoColumnDetail('Products', Product::count());
        $this->components->twoColumnDetail('├─ Available', Product::where('is_available', true)->count());
        $this->components->twoColumnDetail('├─ Low Stock', Product::whereColumn('stock_quantity', '<=', 'low_stock_threshold')->count());
        $this->components->twoColumnDetail('└─ Out of Stock', Product::where('stock_quantity', 0)->count());
        $this->newLine();

        $this->components->twoColumnDetail('Orders', Order::count());
        $this->components->twoColumnDetail('├─ Pending', Order::where('status', 'pending')->count());
        $this->components->twoColumnDetail('├─ Confirmed', Order::where('status', 'confirmed')->count());
        $this->components->twoColumnDetail('├─ In Transit', Order::where('status', 'in_transit')->count());
        $this->components->twoColumnDetail('├─ Delivered', Order::where('status', 'delivered')->count());
        $this->components->twoColumnDetail('└─ Cancelled', Order::where('status', 'cancelled')->count());
        $this->newLine();

        $this->components->twoColumnDetail('Couriers', Courier::count());
        $this->components->twoColumnDetail('├─ Available', Courier::where('is_available', true)->count());
        $this->components->twoColumnDetail('├─ Approved', Courier::where('status', 'approved')->count());
        $this->components->twoColumnDetail('└─ Pending', Courier::where('status', 'pending')->count());
        $this->newLine();

        // Cache Status
        try {
            Cache::put('drpharma_test', 'working', 10);
            $cacheTest = Cache::get('drpharma_test') === 'working';
            $this->components->twoColumnDetail('Cache Status', $cacheTest ? '<fg=green>Working</>' : '<fg=red>Not Working</>');
        } catch (\Exception $e) {
            $this->components->twoColumnDetail('Cache Status', '<fg=red>Error: ' . $e->getMessage() . '</>');
        }
        $this->newLine();

        // Database Connection
        try {
            DB::connection()->getPdo();
            $this->components->twoColumnDetail('Database Connection', '<fg=green>Connected</>');
        } catch (\Exception $e) {
            $this->components->twoColumnDetail('Database Connection', '<fg=red>Failed: ' . $e->getMessage() . '</>');
        }
        $this->newLine();

        $this->info('✅ System status check complete!');
        $this->newLine();

        return self::SUCCESS;
    }
}
