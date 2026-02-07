<?php

namespace App\Filament\Pages;

use App\Models\Order;
use App\Models\Product;
use App\Models\Pharmacy;
use Carbon\Carbon;
use Filament\Pages\Page;
use Filament\Forms\Components\Select;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Tables\Concerns\InteractsWithTable;
use Filament\Tables\Contracts\HasTable;
use Illuminate\Support\Facades\DB;

class ReportsDashboard extends Page implements HasForms
{
    use InteractsWithForms;
    
    protected static ?string $navigationIcon = 'heroicon-o-chart-bar';
    
    protected static ?string $navigationLabel = 'Rapports & Analytics';
    
    protected static ?string $title = 'Rapports & Analytics';
    
    protected static ?string $slug = 'reports-dashboard';
    
    protected static ?int $navigationSort = 2;
    
    protected static ?string $navigationGroup = 'Analytics';

    protected static string $view = 'filament.pages.reports-dashboard';
    
    public string $period = 'week';
    public ?int $pharmacyId = null;
    
    public function mount(): void
    {
        $this->period = 'week';
    }
    
    protected function getFormSchema(): array
    {
        return [
            Select::make('period')
                ->label('Période')
                ->options([
                    'today' => "Aujourd'hui",
                    'week' => 'Cette semaine',
                    'month' => 'Ce mois',
                    'quarter' => 'Ce trimestre',
                    'year' => 'Cette année',
                ])
                ->default('week')
                ->reactive()
                ->afterStateUpdated(fn () => $this->loadData()),
                
            Select::make('pharmacyId')
                ->label('Pharmacie')
                ->options(Pharmacy::where('status', 'approved')->pluck('name', 'id'))
                ->placeholder('Toutes les pharmacies')
                ->reactive()
                ->afterStateUpdated(fn () => $this->loadData()),
        ];
    }
    
    public function getViewData(): array
    {
        $dates = $this->getDateRange();
        
        // Base query with optional pharmacy filter
        $orderQuery = Order::query();
        $productQuery = Product::query();
        
        if ($this->pharmacyId) {
            $orderQuery->where('pharmacy_id', $this->pharmacyId);
            $productQuery->where('pharmacy_id', $this->pharmacyId);
        }
        
        // Sales Stats
        $totalSales = (clone $orderQuery)
            ->whereBetween('created_at', [$dates['start'], $dates['end']])
            ->whereIn('status', ['delivered', 'completed'])
            ->sum('total_amount');
            
        $todaySales = (clone $orderQuery)
            ->whereDate('created_at', Carbon::today())
            ->whereIn('status', ['delivered', 'completed'])
            ->sum('total_amount');
            
        // Previous period for comparison
        $previousDates = $this->getPreviousDateRange();
        $previousSales = (clone $orderQuery)
            ->whereBetween('created_at', [$previousDates['start'], $previousDates['end']])
            ->whereIn('status', ['delivered', 'completed'])
            ->sum('total_amount');
            
        $salesGrowth = $previousSales > 0 
            ? round((($totalSales - $previousSales) / $previousSales) * 100, 1) 
            : 0;
        
        // Orders Stats
        $totalOrders = (clone $orderQuery)
            ->whereBetween('created_at', [$dates['start'], $dates['end']])
            ->count();
            
        $pendingOrders = (clone $orderQuery)
            ->whereIn('status', ['pending', 'confirmed', 'ready'])
            ->count();
            
        $completedOrders = (clone $orderQuery)
            ->whereBetween('created_at', [$dates['start'], $dates['end']])
            ->whereIn('status', ['delivered', 'completed'])
            ->count();
            
        $cancelledOrders = (clone $orderQuery)
            ->whereBetween('created_at', [$dates['start'], $dates['end']])
            ->where('status', 'cancelled')
            ->count();
        
        // Inventory Stats
        $totalProducts = (clone $productQuery)->count();
        $lowStock = (clone $productQuery)
            ->where('stock_quantity', '>', 0)
            ->where('stock_quantity', '<=', 10)
            ->count();
        $outOfStock = (clone $productQuery)
            ->where('stock_quantity', 0)
            ->where('is_available', true)
            ->count();
        $expiringSoon = (clone $productQuery)
            ->whereNotNull('expiry_date')
            ->whereBetween('expiry_date', [Carbon::now(), Carbon::now()->addDays(30)])
            ->count();
            
        // Daily sales for chart
        $dailySales = (clone $orderQuery)
            ->whereBetween('created_at', [$dates['start'], $dates['end']])
            ->whereIn('status', ['delivered', 'completed'])
            ->select(
                DB::raw('DATE(created_at) as date'),
                DB::raw('SUM(total_amount) as total'),
                DB::raw('COUNT(*) as orders_count')
            )
            ->groupBy('date')
            ->orderBy('date')
            ->get();
            
        // Top products
        $topProducts = DB::table('order_items')
            ->join('orders', 'orders.id', '=', 'order_items.order_id')
            ->join('products', 'products.id', '=', 'order_items.product_id')
            ->when($this->pharmacyId, fn($q) => $q->where('orders.pharmacy_id', $this->pharmacyId))
            ->whereBetween('orders.created_at', [$dates['start'], $dates['end']])
            ->whereIn('orders.status', ['delivered', 'completed'])
            ->select(
                'products.id',
                'products.name',
                'products.image',
                DB::raw('SUM(order_items.quantity) as total_sold'),
                DB::raw('SUM(order_items.total_price) as revenue')
            )
            ->groupBy('products.id', 'products.name', 'products.image')
            ->orderByDesc('total_sold')
            ->limit(5)
            ->get();
            
        // Stock alerts
        $stockAlerts = (clone $productQuery)
            ->where(function ($q) {
                $q->where('stock_quantity', '<=', 10)
                  ->where('is_available', true);
            })
            ->orWhere(function ($q) {
                $q->whereNotNull('expiry_date')
                  ->whereBetween('expiry_date', [Carbon::now(), Carbon::now()->addDays(30)])
                  ->where('stock_quantity', '>', 0);
            })
            ->with(['pharmacy', 'category'])
            ->orderBy('stock_quantity')
            ->limit(10)
            ->get();
        
        return [
            'period' => $this->period,
            'periodLabel' => $this->getPeriodLabel(),
            'stats' => [
                'total_sales' => $totalSales,
                'today_sales' => $todaySales,
                'sales_growth' => $salesGrowth,
                'total_orders' => $totalOrders,
                'pending_orders' => $pendingOrders,
                'completed_orders' => $completedOrders,
                'cancelled_orders' => $cancelledOrders,
                'total_products' => $totalProducts,
                'low_stock' => $lowStock,
                'out_of_stock' => $outOfStock,
                'expiring_soon' => $expiringSoon,
            ],
            'daily_sales' => $dailySales,
            'top_products' => $topProducts,
            'stock_alerts' => $stockAlerts,
        ];
    }
    
    public function loadData(): void
    {
        // Trigger re-render
    }
    
    protected function getDateRange(): array
    {
        $end = Carbon::now()->endOfDay();
        
        $start = match($this->period) {
            'today' => Carbon::now()->startOfDay(),
            'week' => Carbon::now()->startOfWeek(),
            'month' => Carbon::now()->startOfMonth(),
            'quarter' => Carbon::now()->startOfQuarter(),
            'year' => Carbon::now()->startOfYear(),
            default => Carbon::now()->startOfWeek(),
        };

        return ['start' => $start, 'end' => $end];
    }
    
    protected function getPreviousDateRange(): array
    {
        $current = $this->getDateRange();
        $diff = $current['start']->diffInDays($current['end']);
        
        return [
            'start' => $current['start']->copy()->subDays($diff + 1),
            'end' => $current['start']->copy()->subDay(),
        ];
    }
    
    protected function getPeriodLabel(): string
    {
        return match($this->period) {
            'today' => "Aujourd'hui",
            'week' => 'Cette semaine',
            'month' => 'Ce mois',
            'quarter' => 'Ce trimestre',
            'year' => 'Cette année',
            default => 'Cette semaine',
        };
    }
}
