<?php

namespace App\Http\Controllers\Api\Customer;

use App\Http\Controllers\Controller;
use App\Models\Pharmacy;
use Illuminate\Http\Request;

class PharmacyController extends Controller
{
    /**
     * Get nearby pharmacies based on GPS coordinates
     */
    public function nearby(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'radius' => 'nullable|numeric|min:1|max:50',
        ]);

        $latitude = $request->latitude;
        $longitude = $request->longitude;
        $radius = $request->radius ?? 10; // Default 10km

        $pharmacies = Pharmacy::approved()
            ->nearLocation($latitude, $longitude, $radius)
            ->get()
            ->map(function ($pharmacy) use ($latitude, $longitude) {
                // Check if pharmacy is currently on duty
                $isOnDuty = $pharmacy->onCalls()
                    ->where('start_at', '<=', now())
                    ->where('end_at', '>=', now())
                    ->where('is_active', true)
                    ->exists();
                
                $currentOnCall = $isOnDuty ? $pharmacy->onCalls()
                    ->where('start_at', '<=', now())
                    ->where('end_at', '>=', now())
                    ->where('is_active', true)
                    ->first() : null;

                return [
                    'id' => $pharmacy->id,
                    'name' => $pharmacy->name,
                    'phone' => $pharmacy->phone,
                    'email' => $pharmacy->email,
                    'address' => $pharmacy->address,
                    'city' => $pharmacy->city,
                    'latitude' => $pharmacy->latitude ? (float) $pharmacy->latitude : null,
                    'longitude' => $pharmacy->longitude ? (float) $pharmacy->longitude : null,
                    'distance' => $pharmacy->distance ?? null,
                    'status' => $pharmacy->status,
                    'is_open' => $pharmacy->is_open ?? true,
                    'is_on_duty' => $isOnDuty,
                    'duty_info' => $currentOnCall ? [
                        'type' => $currentOnCall->type,
                        'end_at' => $currentOnCall->end_at?->toIso8601String(),
                    ] : null,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $pharmacies,
            'meta' => [
                'count' => $pharmacies->count(),
                'radius_km' => $radius,
            ],
        ]);
    }

    /**
     * Get all approved pharmacies
     */
    public function index()
    {
        $pharmacies = Pharmacy::approved()
            ->orderBy('name')
            ->get()
            ->map(function ($pharmacy) {
                // Check if pharmacy is currently on duty
                $isOnDuty = $pharmacy->onCalls()
                    ->where('start_at', '<=', now())
                    ->where('end_at', '>=', now())
                    ->where('is_active', true)
                    ->exists();
                
                $currentOnCall = $isOnDuty ? $pharmacy->onCalls()
                    ->where('start_at', '<=', now())
                    ->where('end_at', '>=', now())
                    ->where('is_active', true)
                    ->first() : null;

                return [
                    'id' => $pharmacy->id,
                    'name' => $pharmacy->name,
                    'phone' => $pharmacy->phone,
                    'email' => $pharmacy->email,
                    'address' => $pharmacy->address,
                    'city' => $pharmacy->city,
                    'latitude' => $pharmacy->latitude ? (float) $pharmacy->latitude : null,
                    'longitude' => $pharmacy->longitude ? (float) $pharmacy->longitude : null,
                    'status' => $pharmacy->status,
                    'is_open' => $pharmacy->is_open ?? true, // Default to open if not specified
                    'is_on_duty' => $isOnDuty,
                    'duty_info' => $currentOnCall ? [
                        'type' => $currentOnCall->type,
                        'end_at' => $currentOnCall->end_at?->toIso8601String(),
                    ] : null,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $pharmacies,
        ]);
    }

    /**
     * Get pharmacy details
     */
    public function show($id)
    {
        $pharmacy = Pharmacy::approved()->findOrFail($id);
        
        // Check if pharmacy is currently on duty
        $isOnDuty = $pharmacy->onCalls()
            ->where('start_at', '<=', now())
            ->where('end_at', '>=', now())
            ->where('is_active', true)
            ->exists();
        
        $currentOnCall = $isOnDuty ? $pharmacy->onCalls()
            ->where('start_at', '<=', now())
            ->where('end_at', '>=', now())
            ->where('is_active', true)
            ->first() : null;

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $pharmacy->id,
                'name' => $pharmacy->name,
                'phone' => $pharmacy->phone,
                'email' => $pharmacy->email,
                'address' => $pharmacy->address,
                'city' => $pharmacy->city,
                'region' => $pharmacy->region,
                'latitude' => $pharmacy->latitude ? (float) $pharmacy->latitude : null,
                'longitude' => $pharmacy->longitude ? (float) $pharmacy->longitude : null,
                'license_number' => $pharmacy->license_number,
                'owner_name' => $pharmacy->owner_name,
                'status' => $pharmacy->status,
                'is_open' => $pharmacy->is_open ?? true,
                'is_on_duty' => $isOnDuty,
                'duty_info' => $currentOnCall ? [
                    'type' => $currentOnCall->type,
                    'end_at' => $currentOnCall->end_at?->toIso8601String(),
                ] : null,
            ],
        ]);
    }

    /**
     * Get pharmacies currently on duty (Garde)
     */
    public function onDuty(Request $request)
    {
        $request->validate([
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'radius' => 'nullable|numeric|min:1|max:50',
        ]);

        $query = Pharmacy::approved()->onDuty();

        // Optional: Filter by location if coordinates are provided
        if ($request->has('latitude') && $request->has('longitude')) {
            $latitude = $request->latitude;
            $longitude = $request->longitude;
            $radius = $request->radius ?? 20; // Default 20km for duty pharmacies (usually wider range)
            
            $query->nearLocation($latitude, $longitude, $radius);
            
            $pharmacies = $query->get()->map(function ($pharmacy) use ($latitude, $longitude) {
                // Get the active on-call shift
                $currentOnCall = $pharmacy->onCalls()
                    ->where('start_at', '<=', now())
                    ->where('end_at', '>=', now())
                    ->where('is_active', true)
                    ->first();

                return [
                    'id' => $pharmacy->id,
                    'name' => $pharmacy->name,
                    'phone' => $pharmacy->phone,
                    'email' => $pharmacy->email,
                    'address' => $pharmacy->address,
                    'city' => $pharmacy->city,
                    'latitude' => $pharmacy->latitude ? (float) $pharmacy->latitude : null,
                    'longitude' => $pharmacy->longitude ? (float) $pharmacy->longitude : null,
                    'distance' => $pharmacy->distance ?? null,
                    'status' => $pharmacy->status,
                    'is_open' => true, // On-duty pharmacies are always considered open
                    'is_on_duty' => true,
                    'duty_info' => $currentOnCall ? [
                         'type' => $currentOnCall->type,
                         'end_at' => $currentOnCall->end_at?->toIso8601String(),
                    ] : null,
                ];
            });
        } else {
             $pharmacies = $query->get()->map(function ($pharmacy) {
                $currentOnCall = $pharmacy->onCalls()
                    ->where('start_at', '<=', now())
                    ->where('end_at', '>=', now())
                    ->where('is_active', true)
                    ->first();

                return [
                    'id' => $pharmacy->id,
                    'name' => $pharmacy->name,
                    'phone' => $pharmacy->phone,
                    'email' => $pharmacy->email,
                    'address' => $pharmacy->address,
                    'city' => $pharmacy->city,
                    'latitude' => $pharmacy->latitude ? (float) $pharmacy->latitude : null,
                    'longitude' => $pharmacy->longitude ? (float) $pharmacy->longitude : null,
                    'status' => $pharmacy->status,
                    'is_open' => true, // On-duty pharmacies are always considered open
                    'is_on_duty' => true,
                    'duty_info' => $currentOnCall ? [
                         'type' => $currentOnCall->type,
                         'end_at' => $currentOnCall->end_at?->toIso8601String(),
                    ] : null,
                ];
            });
        }

        return response()->json([
            'success' => true,
            'data' => $pharmacies,
        ]);
    }
}

