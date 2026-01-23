<?php

namespace App\Http\Controllers\Api\Customer;

use App\Http\Controllers\Controller;
use App\Models\Prescription;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class PrescriptionController extends Controller
{
    /**
     * Get customer prescriptions
     */
    public function index(Request $request)
    {
        $prescriptions = $request->user()->prescriptions()
            ->latest()
            ->get()
            ->map(function ($prescription) {
                return [
                    'id' => $prescription->id,
                    'status' => $prescription->status,
                    'notes' => $prescription->notes,
                    'images' => $prescription->images,
                    'quote_amount' => $prescription->quote_amount,
                    'pharmacy_notes' => $prescription->pharmacy_notes,
                    'created_at' => $prescription->created_at,
                    'validated_at' => $prescription->validated_at,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $prescriptions,
        ]);
    }

    /**
     * Upload a new prescription
     */
    public function upload(Request $request)
    {
        $request->validate([
            'images' => 'required|array|min:1',
            'images.*' => 'required|image|mimes:jpeg,png,jpg|max:5120', // 5MB max per image
            'notes' => 'nullable|string|max:500',
        ]);

        $imagePaths = [];

        foreach ($request->file('images') as $image) {
            $filename = Str::uuid() . '.' . $image->getClientOriginalExtension();
            // Store prescriptions in private storage for security
            $path = $image->storeAs('prescriptions/' . $request->user()->id, $filename, 'private');
            $imagePaths[] = $path;
        }

        $prescription = Prescription::create([
            'customer_id' => $request->user()->id,
            'images' => $imagePaths,
            'notes' => $request->notes,
            'status' => 'pending',
        ]);

        // Notify all pharmacies (or relevant ones based on geolocation in future)
        // For MVP: Notify all users with role 'pharmacy'
        $pharmacies = \App\Models\User::whereHas('roles', function($q) {
            $q->where('name', 'pharmacy');
        })->get();

        foreach($pharmacies as $pharmacy) {
             $pharmacy->notify(new \App\Notifications\NewPrescriptionNotification($prescription));
        }

        return response()->json([
            'success' => true,
            'message' => 'Prescription uploaded successfully',
            'data' => [
                'id' => $prescription->id,
                'status' => $prescription->status,
                'images' => $prescription->images,
                'notes' => $prescription->notes,
                'created_at' => $prescription->created_at,
            ],
        ], 201);
    }

    /**
     * Get prescription details
     */
    public function show(Request $request, $id)
    {
        $prescription = $request->user()->prescriptions()->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $prescription->id,
                'status' => $prescription->status,
                'notes' => $prescription->notes,
                'images' => $prescription->images,
                'admin_notes' => $prescription->admin_notes,
                'pharmacy_notes' => $prescription->pharmacy_notes,
                'quote_amount' => $prescription->quote_amount,
                'created_at' => $prescription->created_at,
                'validated_at' => $prescription->validated_at,
            ],
        ]);
    }

    /**
     * Pay for a quoted prescription.
     */
    public function pay(Request $request, string $id)
    {
        $prescription = \App\Models\Prescription::where('customer_id', $request->user()->id)->findOrFail($id);

        if ($prescription->status !== 'quoted') {
            return response()->json(['message' => 'Cette ordonnance n\'a pas de devis validé.'], 400);
        }

        // 1. Create Order from Prescription
        // In a real app, you might want to create the Order first, then Payment.
        // For this MVP, we simulate a direct transformation.
        
        $pharmacyId = $prescription->validated_by; 
        
        // Let's check if we have a pharmacy attached. 
        $pharmacyUser = \App\Models\User::find($prescription->validated_by);

        // Fallback default for MVP safety if relationship is complex.
        $pharmacyIdToUse = 1; 
        if ($pharmacyUser && $pharmacyUser->pharmacy_id) {
             $pharmacyIdToUse = $pharmacyUser->pharmacy_id;
        } elseif ($pharmacyUser && method_exists($pharmacyUser, 'pharmacies') && $pharmacyUser->pharmacies && $pharmacyUser->pharmacies->first()) {
             $pharmacyIdToUse = $pharmacyUser->pharmacies->first()->id;
        }

        $order = \App\Models\Order::create([
            'reference' => 'ORD-' . strtoupper(uniqid()),
            'pharmacy_id' => $pharmacyIdToUse,
            'customer_id' => $request->user()->id,
            'status' => 'paid', // Immediately paid for this flow
            'payment_mode' => $request->input('payment_method', 'mobile_money'),
            'subtotal' => $prescription->quote_amount,
            'delivery_fee' => 0, // Simplified
            'total_amount' => $prescription->quote_amount,
            'customer_notes' => $prescription->notes,
            'pharmacy_notes' => $prescription->pharmacy_notes,
            'delivery_address' => $request->input('delivery_address', 'Retrait en pharmacie'), // Default or from request
            'prescription_image' => is_array($prescription->images) ? ($prescription->images[0] ?? null) : $prescription->images,
        ]);

        // 2. Create Payment Record
        \App\Models\Payment::create([
            'order_id' => $order->id,
            'provider' => 'cinetpay', // Mock
            'reference' => 'PAY-' . strtoupper(uniqid()),
            'amount' => $prescription->quote_amount,
            'status' => 'SUCCESS',
            'confirmed_at' => now(),
            'payment_method' => $request->input('payment_method', 'mobile_money'),
        ]);

        // 3. Update Prescription Status
        $prescription->update(['status' => 'paid']);

        // 4. Notification? (Optional but good)

        return response()->json([
            'message' => 'Paiement effectué avec succès',
            'order' => $order,
            'prescription_status' => 'paid'
        ]);
    }
}
