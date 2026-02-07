<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    /**
     * Get all products with filters
     */
    public function index(Request $request): JsonResponse
    {
        $query = Product::with('pharmacy')->available();

        // Filter by pharmacy
        if ($request->has('pharmacy_id')) {
            $query->forPharmacy($request->pharmacy_id);
        }

        // Filter by category
        if ($request->has('category')) {
            $query->inCategory($request->category);
        }

        // Search
        if ($request->has('search')) {
            $query->search($request->search);
        }

        // Filter by featured
        if ($request->boolean('featured')) {
            $query->featured();
        }

        // Filter by requires_prescription
        if ($request->has('requires_prescription')) {
            $query->where('requires_prescription', $request->boolean('requires_prescription'));
        }

        // Filter by price range
        if ($request->has('min_price')) {
            $query->where('price', '>=', $request->min_price);
        }
        if ($request->has('max_price')) {
            $query->where('price', '<=', $request->max_price);
        }

        // Sort
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');

        match ($sortBy) {
            'price' => $query->orderBy('price', $sortOrder),
            'name' => $query->orderBy('name', $sortOrder),
            'popular' => $query->orderBy('sales_count', 'desc'),
            'rating' => $query->orderBy('average_rating', 'desc'),
            default => $query->orderBy('created_at', $sortOrder),
        };

        $products = $query->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => [
                'products' => $products->items(),
                'pagination' => [
                    'current_page' => $products->currentPage(),
                    'last_page' => $products->lastPage(),
                    'per_page' => $products->perPage(),
                    'total' => $products->total(),
                ],
            ],
        ]);
    }

    /**
     * Get single product details
     */
    public function show(int $id): JsonResponse
    {
        $product = Product::with('pharmacy')->findOrFail($id);

        // Increment view count
        $product->incrementViews();

        return response()->json([
            'success' => true,
            'data' => [
                'product' => $product,
            ],
        ]);
    }

    /**
     * Get products by slug
     */
    public function showBySlug(string $slug): JsonResponse
    {
        $product = Product::with('pharmacy')->where('slug', $slug)->firstOrFail();

        // Increment view count
        $product->incrementViews();

        return response()->json([
            'success' => true,
            'data' => [
                'product' => $product,
            ],
        ]);
    }

    /**
     * Get featured products
     */
    public function featured(Request $request): JsonResponse
    {
        $products = Product::with('pharmacy')
            ->available()
            ->featured()
            ->orderBy('sales_count', 'desc')
            ->limit($request->get('limit', 10))
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'products' => $products,
            ],
        ]);
    }

    /**
     * Get products by category
     */
    public function byCategory(Request $request, string $category): JsonResponse
    {
        $products = Product::with('pharmacy')
            ->available()
            ->inCategory($category)
            ->orderBy('sales_count', 'desc')
            ->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => [
                'category' => $category,
                'products' => $products->items(),
                'pagination' => [
                    'current_page' => $products->currentPage(),
                    'last_page' => $products->lastPage(),
                    'per_page' => $products->perPage(),
                    'total' => $products->total(),
                ],
            ],
        ]);
    }

    /**
     * Get available categories
     */
    public function categories(): JsonResponse
    {
        $categories = Product::where('is_available', true)
            ->distinct()
            ->pluck('category')
            ->filter()
            ->values();

        return response()->json([
            'success' => true,
            'data' => [
                'categories' => $categories,
            ],
        ]);
    }

    /**
     * Search products
     */
    public function search(Request $request): JsonResponse
    {
        $request->validate([
            'q' => 'required|string|min:2',
        ]);

        $products = Product::with('pharmacy')
            ->available()
            ->search($request->q)
            ->orderBy('sales_count', 'desc')
            ->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => [
                'query' => $request->q,
                'products' => $products->items(),
                'pagination' => [
                    'current_page' => $products->currentPage(),
                    'last_page' => $products->lastPage(),
                    'per_page' => $products->perPage(),
                    'total' => $products->total(),
                ],
            ],
        ]);
    }
}
