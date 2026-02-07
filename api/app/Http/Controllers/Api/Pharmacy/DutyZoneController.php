<?php

namespace App\Http\Controllers\Api\Pharmacy;

use App\Http\Controllers\Controller;
use App\Models\DutyZone;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class DutyZoneController extends Controller
{
    /**
     * List all active duty zones.
     */
    public function index(): JsonResponse
    {
        $zones = DutyZone::where('is_active', true)
            ->orderBy('name')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $zones
        ]);
    }

    /**
     * Show details of a specific duty zone.
     */
    public function show($id): JsonResponse
    {
        $zone = DutyZone::where('is_active', true)->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $zone
        ]);
    }
}
