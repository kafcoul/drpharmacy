<?php

namespace App\Filament\Pharmacy\Widgets;

use App\Models\Order;
use App\Models\Product;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Facades\Auth;

class PharmacyStatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        $pharmacy = Auth::user()->pharmacies->first();

        if (!$pharmacy) {
            return [];
        }

        $todayOrders = Order::where('pharmacy_id', $pharmacy->id)
            ->whereDate('created_at', today())
            ->count();

        $todayRevenue = Order::where('pharmacy_id', $pharmacy->id)
            ->whereDate('created_at', today())
            ->whereIn('status', ['confirmed', 'delivered', 'paid'])
            ->sum('total_amount');

        $lowStockCount = Product::where('pharmacy_id', $pharmacy->id)
            ->whereColumn('stock_quantity', '<=', 'low_stock_threshold')
            ->count();

        return [
            Stat::make('Commandes du jour', $todayOrders)
                ->description('Nouvelles commandes')
                ->descriptionIcon('heroicon-m-shopping-bag')
                ->color('primary'),
            
            Stat::make('Revenus du jour', number_format($todayRevenue, 0, ',', ' ') . ' FCFA')
                ->description('Chiffre d\'affaires estimé')
                ->descriptionIcon('heroicon-m-banknotes')
                ->color('success'),

            Stat::make('Alertes Stock', $lowStockCount)
                ->description('Produits en stock faible')
                ->descriptionIcon('heroicon-m-exclamation-triangle')
                ->color('danger'),
        ];
    }
}
