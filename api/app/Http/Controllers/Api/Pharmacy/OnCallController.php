<?php

namespace App\Http\Controllers\Api\Pharmacy;

use App\Http\Controllers\Controller;
use App\Models\PharmacyOnCall;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class OnCallController extends Controller
{
    /**
     * List on-call shifts for the authenticated pharmacy.
     */
    public function index(Request $request): JsonResponse
    {
        $user = Auth::user();
        
        // Assuming the user is linked to a pharmacy somehow. 
        // Based on PharmacyResource, there is a pharmacy_user table.
        // We need to find the pharmacy associated with this user.
        $pharmacy = $user->pharmacies()->first();

        if (!$pharmacy) {
            return response()->json([
                'status' => 'error',
                'message' => 'User is not associated with any pharmacy.'
            ], 403);
        }

        $query = PharmacyOnCall::with('dutyZone')
            ->where('pharmacy_id', $pharmacy->id)
            ->orderBy('start_at', 'desc');

        if ($request->has('active_only')) {
            $query->where('is_active', true)
                  ->where('end_at', '>=', now());
        }

        return response()->json([
            'status' => 'success',
            'data' => $query->paginate(20)
        ]);
    }

    /**
     * Declare an on-call shift (Garde).
     */
    public function store(Request $request): JsonResponse
    {
        $user = Auth::user();
        $pharmacy = $user->pharmacies()->first();

        if (!$pharmacy) {
            return response()->json([
                'status' => 'error',
                'message' => 'User is not associated with any pharmacy.'
            ], 403);
        }

        $validated = $request->validate([
            // 'duty_zone_id' => 'required|exists:duty_zones,id', // Removed: Inferred from Pharmacy
            'start_at' => 'required|date|after:now',
            'end_at' => 'required|date|after:start_at',
            'type' => ['required', Rule::in(['night', 'weekend', 'holiday', 'emergency'])],
        ]);

        // Infer Zone
        $zoneId = $pharmacy->duty_zone_id;
        
        // If pharmacy has no zone, we might need to error or allow nullable.
        // For now, let's assume all pharmacies MUST have a zone as per registration update.
        if (!$zoneId) {
             return response()->json([
                'status' => 'error',
                'message' => 'Your pharmacy does not have an assigned Duty Zone. Please update your profile.'
            ], 422);
        }

        $onCall = PharmacyOnCall::create([
            'pharmacy_id' => $pharmacy->id,
            'duty_zone_id' => $zoneId,
            'start_at' => $validated['start_at'],
            'end_at' => $validated['end_at'],
            'type' => $validated['type'],
            'is_active' => true,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'On-call shift declared successfully.',
            'data' => $onCall
        ], 201);
    }

    /**
     * Update an on-call shift.
     */
    public function update(Request $request, $id): JsonResponse
    {
        $user = Auth::user();
        $pharmacy = $user->pharmacies()->first();

        if (!$pharmacy) {
            return response()->json([
                'status' => 'error',
                'message' => 'User is not associated with any pharmacy.'
            ], 403);
        }

        $onCall = PharmacyOnCall::where('pharmacy_id', $pharmacy->id)->findOrFail($id);

        $validated = $request->validate([
            'duty_zone_id' => 'exists:duty_zones,id',
            'start_at' => 'date',
            'end_at' => 'date|after:start_at',
            'type' => [Rule::in(['night', 'weekend', 'holiday', 'emergency'])],
            'is_active' => 'boolean',
        ]);

        $onCall->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'On-call shift updated successfully.',
            'data' => $onCall
        ]);
    }

    /**
     * Delete (cancel) an on-call shift.
     */
    public function destroy($id): JsonResponse
    {
        $user = Auth::user();
        $pharmacy = $user->pharmacies()->first();

        if (!$pharmacy) {
            return response()->json([
                'status' => 'error',
                'message' => 'User is not associated with any pharmacy.'
            ], 403);
        }

        $onCall = PharmacyOnCall::where('pharmacy_id', $pharmacy->id)->findOrFail($id);
        $onCall->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'On-call shift cancelled successfully.'
        ]);
    }
}
