<?php

namespace App\Http\Controllers\Api\Pharmacy;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use App\Models\OrderItem;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportsController extends Controller
{
    private function getPharmacy($user)
    {
        return $user->pharmacies()->where('status', 'approved')->first();
    }

    /**
     * Get dashboard overview stats
     */
    public function overview(Request $request)
    {
        $pharmacy = $this->getPharmacy($request->user());

        if (!$pharmacy) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune pharmacie approuvée associée.',
            ], 403);
        }

        $period = $request->get('period', 'week'); // today, week, month, quarter, year
        $dates = $this->getDateRange($period);

        // Sales stats
        $salesData = $this->getSalesStats($pharmacy->id, $dates);
        
        // Orders stats
        $ordersData = $this->getOrdersStats($pharmacy->id, $dates);
        
        // Inventory stats
        $inventoryData = $this->getInventoryStats($pharmacy->id);

        return response()->json([
            'success' => true,
            'data' => [
                'period' => $period,
                'date_range' => [
                    'start' => $dates['start']->toDateString(),
                    'end' => $dates['end']->toDateString(),
                ],
                'sales' => $salesData,
                'orders' => $ordersData,
                'inventory' => $inventoryData,
            ]
        ]);
    }

    /**
     * Get detailed sales report
     */
    public function sales(Request $request)
    {
        $pharmacy = $this->getPharmacy($request->user());

        if (!$pharmacy) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune pharmacie approuvée associée.',
            ], 403);
        }

        $period = $request->get('period', 'week');
        $dates = $this->getDateRange($period);

        // Daily sales for the period
        $dailySales = Order::where('pharmacy_id', $pharmacy->id)
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
        $topProducts = OrderItem::whereHas('order', function ($q) use ($pharmacy, $dates) {
            $q->where('pharmacy_id', $pharmacy->id)
                ->whereBetween('created_at', [$dates['start'], $dates['end']])
                ->whereIn('status', ['delivered', 'completed']);
        })
            ->select(
                'product_id',
                DB::raw('SUM(quantity) as total_sold'),
                DB::raw('SUM(subtotal) as revenue')
            )
            ->with('product:id,name,image')
            ->groupBy('product_id')
            ->orderByDesc('total_sold')
            ->limit(10)
            ->get();

        // Comparison with previous period
        $previousDates = $this->getPreviousDateRange($period);
        $previousTotal = Order::where('pharmacy_id', $pharmacy->id)
            ->whereBetween('created_at', [$previousDates['start'], $previousDates['end']])
            ->whereIn('status', ['delivered', 'completed'])
            ->sum('total_amount');

        $currentTotal = Order::where('pharmacy_id', $pharmacy->id)
            ->whereBetween('created_at', [$dates['start'], $dates['end']])
            ->whereIn('status', ['delivered', 'completed'])
            ->sum('total_amount');

        $growth = $previousTotal > 0 
            ? round((($currentTotal - $previousTotal) / $previousTotal) * 100, 1) 
            : 0;

        return response()->json([
            'success' => true,
            'data' => [
                'period' => $period,
                'total' => $currentTotal,
                'previous_total' => $previousTotal,
                'growth_percentage' => $growth,
                'daily_sales' => $dailySales,
                'top_products' => $topProducts,
            ]
        ]);
    }

    /**
     * Get orders report
     */
    public function orders(Request $request)
    {
        $pharmacy = $this->getPharmacy($request->user());

        if (!$pharmacy) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune pharmacie approuvée associée.',
            ], 403);
        }

        $period = $request->get('period', 'week');
        $dates = $this->getDateRange($period);

        // Orders by status
        $ordersByStatus = Order::where('pharmacy_id', $pharmacy->id)
            ->whereBetween('created_at', [$dates['start'], $dates['end']])
            ->select('status', DB::raw('COUNT(*) as count'))
            ->groupBy('status')
            ->get()
            ->pluck('count', 'status');

        // Daily orders
        $dailyOrders = Order::where('pharmacy_id', $pharmacy->id)
            ->whereBetween('created_at', [$dates['start'], $dates['end']])
            ->select(
                DB::raw('DATE(created_at) as date'),
                DB::raw('COUNT(*) as total'),
                DB::raw('SUM(CASE WHEN status IN ("delivered", "completed") THEN 1 ELSE 0 END) as completed'),
                DB::raw('SUM(CASE WHEN status = "cancelled" THEN 1 ELSE 0 END) as cancelled')
            )
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // Average order value
        $avgOrderValue = Order::where('pharmacy_id', $pharmacy->id)
            ->whereBetween('created_at', [$dates['start'], $dates['end']])
            ->whereIn('status', ['delivered', 'completed'])
            ->avg('total_amount') ?? 0;

        return response()->json([
            'success' => true,
            'data' => [
                'period' => $period,
                'by_status' => [
                    'total' => array_sum($ordersByStatus->toArray()),
                    'pending' => ($ordersByStatus['pending'] ?? 0) + ($ordersByStatus['confirmed'] ?? 0),
                    'completed' => ($ordersByStatus['delivered'] ?? 0) + ($ordersByStatus['completed'] ?? 0),
                    'cancelled' => $ordersByStatus['cancelled'] ?? 0,
                ],
                'daily_orders' => $dailyOrders,
                'average_order_value' => round($avgOrderValue, 0),
            ]
        ]);
    }

    /**
     * Get inventory report with alerts
     */
    public function inventory(Request $request)
    {
        $pharmacy = $this->getPharmacy($request->user());

        if (!$pharmacy) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune pharmacie approuvée associée.',
            ], 403);
        }

        // Get all products with stock info
        $products = Product::where('pharmacy_id', $pharmacy->id)->get();

        $totalProducts = $products->count();
        $outOfStock = $products->where('stock_quantity', 0)->count();
        $lowStock = $products->where('stock_quantity', '>', 0)->where('stock_quantity', '<=', 10)->count();
        
        // Products expiring in 30 days
        $expiringSoon = Product::where('pharmacy_id', $pharmacy->id)
            ->whereNotNull('expiry_date')
            ->whereBetween('expiry_date', [Carbon::now(), Carbon::now()->addDays(30)])
            ->count();

        // Products by category
        $byCategory = Product::where('pharmacy_id', $pharmacy->id)
            ->select('category_id', DB::raw('COUNT(*) as count'), DB::raw('SUM(stock_quantity) as total_stock'))
            ->with('category:id,name')
            ->groupBy('category_id')
            ->get();

        // Stock value
        $stockValue = Product::where('pharmacy_id', $pharmacy->id)
            ->selectRaw('SUM(price * stock_quantity) as total_value')
            ->value('total_value') ?? 0;

        return response()->json([
            'success' => true,
            'data' => [
                'summary' => [
                    'total_products' => $totalProducts,
                    'out_of_stock' => $outOfStock,
                    'low_stock' => $lowStock,
                    'expiring_soon' => $expiringSoon,
                    'stock_value' => round($stockValue, 0),
                ],
                'by_category' => $byCategory,
            ]
        ]);
    }

    /**
     * Get stock alerts
     */
    public function stockAlerts(Request $request)
    {
        $pharmacy = $this->getPharmacy($request->user());

        if (!$pharmacy) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune pharmacie approuvée associée.',
            ], 403);
        }

        $alerts = [];

        // Critical: Out of stock
        $outOfStock = Product::where('pharmacy_id', $pharmacy->id)
            ->where('stock_quantity', 0)
            ->where('is_available', true)
            ->select('id', 'name', 'stock_quantity', 'image', 'category_id')
            ->with('category:id,name')
            ->get();

        foreach ($outOfStock as $product) {
            $alerts[] = [
                'id' => 'stock_' . $product->id,
                'type' => 'out_of_stock',
                'severity' => 'critical',
                'title' => 'Rupture de stock',
                'message' => $product->name . ' est en rupture de stock',
                'product_id' => $product->id,
                'product_name' => $product->name,
                'product_image' => $product->image,
                'category' => $product->category?->name,
                'current_quantity' => 0,
                'suggested_action' => 'reorder',
            ];
        }

        // Warning: Low stock (1-10 units)
        $lowStock = Product::where('pharmacy_id', $pharmacy->id)
            ->where('stock_quantity', '>', 0)
            ->where('stock_quantity', '<=', 10)
            ->where('is_available', true)
            ->select('id', 'name', 'stock_quantity', 'image', 'category_id')
            ->with('category:id,name')
            ->get();

        foreach ($lowStock as $product) {
            $alerts[] = [
                'id' => 'stock_' . $product->id,
                'type' => 'low_stock',
                'severity' => 'warning',
                'title' => 'Stock faible',
                'message' => $product->name . ' - ' . $product->stock_quantity . ' unités restantes',
                'product_id' => $product->id,
                'product_name' => $product->name,
                'product_image' => $product->image,
                'category' => $product->category?->name,
                'current_quantity' => $product->stock_quantity,
                'suggested_action' => 'reorder',
            ];
        }

        // Warning: Expiring soon (within 30 days)
        $expiringSoon = Product::where('pharmacy_id', $pharmacy->id)
            ->whereNotNull('expiry_date')
            ->whereBetween('expiry_date', [Carbon::now(), Carbon::now()->addDays(30)])
            ->where('stock_quantity', '>', 0)
            ->select('id', 'name', 'stock_quantity', 'expiry_date', 'image', 'category_id')
            ->with('category:id,name')
            ->orderBy('expiry_date')
            ->get();

        foreach ($expiringSoon as $product) {
            $daysUntilExpiry = Carbon::now()->diffInDays($product->expiry_date);
            $severity = $daysUntilExpiry <= 7 ? 'critical' : 'warning';
            
            $alerts[] = [
                'id' => 'expiry_' . $product->id,
                'type' => 'expiring_soon',
                'severity' => $severity,
                'title' => 'Expiration proche',
                'message' => $product->name . ' expire dans ' . $daysUntilExpiry . ' jours',
                'product_id' => $product->id,
                'product_name' => $product->name,
                'product_image' => $product->image,
                'category' => $product->category?->name,
                'current_quantity' => $product->stock_quantity,
                'expiry_date' => $product->expiry_date->toDateString(),
                'days_until_expiry' => $daysUntilExpiry,
                'suggested_action' => 'discount',
            ];
        }

        // Sort by severity (critical first)
        usort($alerts, function ($a, $b) {
            $severityOrder = ['critical' => 0, 'warning' => 1, 'info' => 2];
            return $severityOrder[$a['severity']] <=> $severityOrder[$b['severity']];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'total_alerts' => count($alerts),
                'critical_count' => count(array_filter($alerts, fn($a) => $a['severity'] === 'critical')),
                'warning_count' => count(array_filter($alerts, fn($a) => $a['severity'] === 'warning')),
                'alerts' => $alerts,
            ]
        ]);
    }

    /**
     * Export report data
     */
    public function export(Request $request)
    {
        $pharmacy = $this->getPharmacy($request->user());

        if (!$pharmacy) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune pharmacie approuvée associée.',
            ], 403);
        }

        $type = $request->get('type', 'sales'); // sales, orders, inventory
        $format = $request->get('format', 'json'); // json, csv
        $period = $request->get('period', 'month');

        // For now, return JSON data that can be exported client-side
        // In production, you'd generate PDF/Excel files
        
        $dates = $this->getDateRange($period);

        $data = match($type) {
            'sales' => $this->getSalesExportData($pharmacy->id, $dates),
            'orders' => $this->getOrdersExportData($pharmacy->id, $dates),
            'inventory' => $this->getInventoryExportData($pharmacy->id),
            default => [],
        };

        return response()->json([
            'success' => true,
            'data' => [
                'type' => $type,
                'format' => $format,
                'period' => $period,
                'generated_at' => Carbon::now()->toIso8601String(),
                'pharmacy_name' => $pharmacy->name,
                'content' => $data,
            ]
        ]);
    }

    // Helper methods

    private function getDateRange(string $period): array
    {
        $end = Carbon::now()->endOfDay();
        
        $start = match($period) {
            'today' => Carbon::now()->startOfDay(),
            'week' => Carbon::now()->startOfWeek(),
            'month' => Carbon::now()->startOfMonth(),
            'quarter' => Carbon::now()->startOfQuarter(),
            'year' => Carbon::now()->startOfYear(),
            default => Carbon::now()->startOfWeek(),
        };

        return ['start' => $start, 'end' => $end];
    }

    private function getPreviousDateRange(string $period): array
    {
        $current = $this->getDateRange($period);
        $diff = $current['start']->diffInDays($current['end']);
        
        return [
            'start' => $current['start']->copy()->subDays($diff + 1),
            'end' => $current['start']->copy()->subDay(),
        ];
    }

    private function getSalesStats(int $pharmacyId, array $dates): array
    {
        $today = Order::where('pharmacy_id', $pharmacyId)
            ->whereDate('created_at', Carbon::today())
            ->whereIn('status', ['delivered', 'completed'])
            ->sum('total_amount');

        $yesterday = Order::where('pharmacy_id', $pharmacyId)
            ->whereDate('created_at', Carbon::yesterday())
            ->whereIn('status', ['delivered', 'completed'])
            ->sum('total_amount');

        $periodTotal = Order::where('pharmacy_id', $pharmacyId)
            ->whereBetween('created_at', [$dates['start'], $dates['end']])
            ->whereIn('status', ['delivered', 'completed'])
            ->sum('total_amount');

        $previousDates = $this->getPreviousDateRange('week');
        $previousTotal = Order::where('pharmacy_id', $pharmacyId)
            ->whereBetween('created_at', [$previousDates['start'], $previousDates['end']])
            ->whereIn('status', ['delivered', 'completed'])
            ->sum('total_amount');

        $growth = $previousTotal > 0 
            ? round((($periodTotal - $previousTotal) / $previousTotal) * 100, 1) 
            : 0;

        return [
            'today' => $today,
            'yesterday' => $yesterday,
            'period_total' => $periodTotal,
            'growth' => $growth,
        ];
    }

    private function getOrdersStats(int $pharmacyId, array $dates): array
    {
        $stats = Order::where('pharmacy_id', $pharmacyId)
            ->whereBetween('created_at', [$dates['start'], $dates['end']])
            ->select('status', DB::raw('COUNT(*) as count'))
            ->groupBy('status')
            ->get()
            ->pluck('count', 'status');

        return [
            'total' => array_sum($stats->toArray()),
            'pending' => ($stats['pending'] ?? 0) + ($stats['confirmed'] ?? 0) + ($stats['ready'] ?? 0),
            'completed' => ($stats['delivered'] ?? 0) + ($stats['completed'] ?? 0),
            'cancelled' => $stats['cancelled'] ?? 0,
        ];
    }

    private function getInventoryStats(int $pharmacyId): array
    {
        $products = Product::where('pharmacy_id', $pharmacyId)->get();
        
        return [
            'total_products' => $products->count(),
            'low_stock' => $products->where('stock_quantity', '>', 0)->where('stock_quantity', '<=', 10)->count(),
            'out_of_stock' => $products->where('stock_quantity', 0)->count(),
            'expiring_soon' => Product::where('pharmacy_id', $pharmacyId)
                ->whereNotNull('expiry_date')
                ->whereBetween('expiry_date', [Carbon::now(), Carbon::now()->addDays(30)])
                ->count(),
        ];
    }

    private function getSalesExportData(int $pharmacyId, array $dates): array
    {
        return Order::where('pharmacy_id', $pharmacyId)
            ->whereBetween('created_at', [$dates['start'], $dates['end']])
            ->whereIn('status', ['delivered', 'completed'])
            ->with('items.product:id,name')
            ->select('id', 'order_number', 'total_amount', 'status', 'created_at')
            ->get()
            ->toArray();
    }

    private function getOrdersExportData(int $pharmacyId, array $dates): array
    {
        return Order::where('pharmacy_id', $pharmacyId)
            ->whereBetween('created_at', [$dates['start'], $dates['end']])
            ->select('id', 'order_number', 'total_amount', 'status', 'created_at')
            ->get()
            ->toArray();
    }

    private function getInventoryExportData(int $pharmacyId): array
    {
        return Product::where('pharmacy_id', $pharmacyId)
            ->with('category:id,name')
            ->select('id', 'name', 'price', 'stock_quantity', 'category_id', 'expiry_date', 'is_available')
            ->get()
            ->toArray();
    }
}
