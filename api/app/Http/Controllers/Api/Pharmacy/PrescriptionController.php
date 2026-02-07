<?php

namespace App\Http\Controllers\Api\Pharmacy;

use App\Http\Controllers\Controller;
use App\Models\Prescription;
use App\Http\Resources\PrescriptionResource;
use Illuminate\Http\Request;

class PrescriptionController extends Controller
{
    /**
     * Display a listing of the prescriptions.
     */
    public function index(Request $request)
    {
        // For MVP, show all prescriptions. In real app, maybe filter by location or assignment.
        $prescriptions = Prescription::with('customer')
            ->latest()
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => PrescriptionResource::collection($prescriptions)
        ]);
    }

    /**
     * Display the specified prescription.
     */
    public function show($id)
    {
        $prescription = Prescription::with('customer')->find($id);

        if (!$prescription) {
            return response()->json([
                'status' => 'error',
                'message' => 'Prescription not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => new PrescriptionResource($prescription)
        ]);
    }

    /**
     * Update the prescription status (Validate/Reject).
     */
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:validated,rejected,pending,quoted',
            'admin_notes' => 'nullable|string',
            'quote_amount' => 'nullable|numeric|min:0',
            'pharmacy_notes' => 'nullable|string',
        ]);

        $prescription = Prescription::find($id);

        if (!$prescription) {
            return response()->json([
                'status' => 'error',
                'message' => 'Prescription not found'
            ], 404);
        }

        $prescription->status = $request->status;
        
        if ($request->has('admin_notes')) {
            $prescription->admin_notes = $request->admin_notes;
        }

        if ($request->has('pharmacy_notes')) {
            $prescription->pharmacy_notes = $request->pharmacy_notes;
        }

        if ($request->has('quote_amount')) {
            $prescription->quote_amount = $request->quote_amount;
        }
        
        if ($request->status === 'validated' || $request->status === 'quoted') {
            $prescription->validated_at = now();
            $prescription->validated_by = $request->user()->id; 
        }

        $prescription->save();

        // Notify Customer
        if ($prescription->customer) {
            $prescription->customer->notify(new \App\Notifications\PrescriptionStatusNotification($prescription, $request->status));
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Prescription status updated successfully',
            'data' => new PrescriptionResource($prescription)
        ]);
    }
}
