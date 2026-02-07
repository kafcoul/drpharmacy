<?php

namespace App\Console\Commands;

use App\Services\CacheService;
use Illuminate\Console\Command;

class CacheClear extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'drpharma:cache:clear {--all : Clear all cache}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Clear DR-PHARMA application cache';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $this->info('🔄 Clearing DR-PHARMA cache...');
        $this->newLine();

        if ($this->option('all')) {
            CacheService::clearAll();
            $this->info('✅ All cache cleared successfully!');
        } else {
            $this->components->task('Application Cache', function () {
                $this->call('cache:clear');
            });

            $this->components->task('Route Cache', function () {
                $this->call('route:clear');
            });

            $this->components->task('Config Cache', function () {
                $this->call('config:clear');
            });

            $this->components->task('View Cache', function () {
                $this->call('view:clear');
            });

            $this->newLine();
            $this->info('✅ Cache cleared successfully!');
        }

        return self::SUCCESS;
    }
}
