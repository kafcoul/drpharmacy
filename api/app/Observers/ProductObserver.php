<?php

namespace App\Observers;

use App\Models\Product;
use App\Services\CacheService;
use Illuminate\Support\Facades\Log;

class ProductObserver
{
    /**
     * Handle the Product "created" event.
     */
    public function created(Product $product): void
    {
        Log::info("Product created: {$product->id}");
        CacheService::forgetProductList();
    }

    /**
     * Handle the Product "updated" event.
     */
    public function updated(Product $product): void
    {
        Log::info("Product updated: {$product->id}");
        CacheService::forgetProduct($product->id);
        CacheService::forgetProductList();
    }

    /**
     * Handle the Product "deleted" event.
     */
    public function deleted(Product $product): void
    {
        Log::info("Product deleted: {$product->id}");
        CacheService::forgetProduct($product->id);
        CacheService::forgetProductList();
    }

    /**
     * Handle the Product "restored" event.
     */
    public function restored(Product $product): void
    {
        Log::info("Product restored: {$product->id}");
        CacheService::forgetProductList();
    }
}
