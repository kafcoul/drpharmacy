<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\OtpService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class RegisterController extends Controller
{
    protected $otpService;

    public function __construct(OtpService $otpService)
    {
        $this->otpService = $otpService;
    }

    /**
     * Register a new customer
     */
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'required|string|max:20|unique:users',
            'password' => ['required', 'confirmed', Password::min(8)],
            'device_name' => 'string',
        ]);

        // Normaliser l'email en minuscules pour éviter les problèmes de case sensitivity
        $validated['email'] = strtolower(trim($validated['email']));

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'phone' => $validated['phone'],
            'password' => Hash::make($validated['password']),
            'role' => 'customer',
        ]);

        // Send OTP
        $otp = $this->otpService->generateOtp($user->phone); // Prefer phone for mobile apps
        $this->otpService->sendOtp($user->phone, $otp);

        // Create token
        $token = $user->createToken($request->device_name ?? 'mobile-app')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Inscription réussie. Veuillez vérifier votre compte.',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'role' => $user->role,
                    'phone_verified_at' => $user->phone_verified_at,
                ],
                'token' => $token,
            ],
        ], 201);
    }

    /**
     * Register a new courier with KYC documents (recto/verso)
     */
    public function registerCourier(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'required|string|max:20|unique:users',
            'password' => ['required', 'confirmed', Password::min(8)],
            'vehicle_type' => 'required|in:motorcycle,car,bicycle',
            'vehicle_registration' => 'required|string|max:50',
            'license_number' => 'nullable|string|max:50',
            'device_name' => 'nullable|string',
            // KYC Documents - Recto/Verso
            'id_card_front_document' => 'required|file|mimetypes:image/jpeg,image/png,application/pdf|max:5120',
            'id_card_back_document' => 'required|file|mimetypes:image/jpeg,image/png,application/pdf|max:5120',
            'selfie_document' => 'required|file|mimetypes:image/jpeg,image/png|max:5120',
            'driving_license_front_document' => 'nullable|file|mimetypes:image/jpeg,image/png,application/pdf|max:5120',
            'driving_license_back_document' => 'nullable|file|mimetypes:image/jpeg,image/png,application/pdf|max:5120',
        ]);

        DB::beginTransaction();
        
        try {
            // Normaliser l'email en minuscules pour éviter les problèmes de case sensitivity
            $validated['email'] = strtolower(trim($validated['email']));

            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'phone' => $validated['phone'],
                'password' => Hash::make($validated['password']),
                'role' => 'courier',
            ]);

            // Handle KYC document uploads - Recto/Verso
            $idCardFrontPath = null;
            $idCardBackPath = null;
            $selfiePath = null;
            $drivingLicenseFrontPath = null;
            $drivingLicenseBackPath = null;

            if ($request->hasFile('id_card_front_document')) {
                $idCardFrontPath = $request->file('id_card_front_document')
                    ->store("courier-documents/{$user->id}", 'private');
            }

            if ($request->hasFile('id_card_back_document')) {
                $idCardBackPath = $request->file('id_card_back_document')
                    ->store("courier-documents/{$user->id}", 'private');
            }

            if ($request->hasFile('selfie_document')) {
                $selfiePath = $request->file('selfie_document')
                    ->store("courier-documents/{$user->id}", 'private');
            }

            if ($request->hasFile('driving_license_front_document')) {
                $drivingLicenseFrontPath = $request->file('driving_license_front_document')
                    ->store("courier-documents/{$user->id}", 'private');
            }

            if ($request->hasFile('driving_license_back_document')) {
                $drivingLicenseBackPath = $request->file('driving_license_back_document')
                    ->store("courier-documents/{$user->id}", 'private');
            }

            // Create courier profile with KYC documents (recto/verso)
            $user->courier()->create([
                'name' => $user->name,
                'phone' => $user->phone,
                'vehicle_type' => $validated['vehicle_type'],
                'vehicle_number' => $validated['vehicle_registration'],
                'license_number' => $validated['license_number'] ?? null,
                'id_card_front_document' => $idCardFrontPath,
                'id_card_back_document' => $idCardBackPath,
                'selfie_document' => $selfiePath,
                'driving_license_front_document' => $drivingLicenseFrontPath,
                'driving_license_back_document' => $drivingLicenseBackPath,
                'status' => 'pending_approval',
                'kyc_status' => ($idCardFrontPath && $idCardBackPath && $selfiePath) ? 'pending_review' : 'incomplete',
            ]);

            // Send OTP for phone verification
            $otp = $this->otpService->generateOtp($user->phone);
            $this->otpService->sendOtp($user->phone, $otp);

            // NE PAS créer de token pour les coursiers en attente d'approbation
            // Le token sera créé uniquement lors de la connexion après approbation admin

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Inscription livreur réussie. Votre compte est en attente d\'approbation par l\'administrateur. Vous recevrez une notification une fois approuvé.',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'phone' => $user->phone,
                        'role' => $user->role,
                        'status' => 'pending_approval',
                    ],
                    // Pas de token - le coursier doit attendre l'approbation
                    'requires_approval' => true,
                ],
            ], 201);
            
        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'inscription: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Register a new pharmacy
     */
    public function registerPharmacy(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'required|string|max:20|unique:users',
            'password' => ['required', 'confirmed', Password::min(8)],
            'pharmacy_name' => 'required|string|max:255',
            'pharmacy_license' => 'required|string|max:50',
            // 'license_document' => 'nullable|file|mimes:pdf,jpg,jpeg,png|max:5120', // Moved to profile verification
            'pharmacy_address' => 'required|string',
            'city' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',

            'device_name' => 'string',
        ]);

        DB::beginTransaction();

        try {
            // Normaliser l'email en minuscules pour éviter les problèmes de case sensitivity
            $validated['email'] = strtolower(trim($validated['email']));

            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'phone' => $validated['phone'],
                'password' => Hash::make($validated['password']),
                'role' => 'pharmacy',
            ]);

            // Create pharmacy
            $pharmacy = \App\Models\Pharmacy::create([
                'name' => $validated['pharmacy_name'],
                'phone' => $validated['phone'],
                'email' => $validated['email'],  // Déjà en minuscules
                'address' => $validated['pharmacy_address'],
                'city' => $validated['city'],
                'license_number' => $validated['pharmacy_license'],
                // 'license_document' => $licensePath, // Moved to profile verification
                'owner_name' => $validated['name'],
                'latitude' => $validated['latitude'] ?? null,
                'longitude' => $validated['longitude'] ?? null,
                'status' => 'pending',
            ]);

            // Attach user to pharmacy
            $pharmacy->users()->attach($user->id, ['role' => 'owner']);

            // Send OTP
            $otp = $this->otpService->generateOtp($user->phone);
            $this->otpService->sendOtp($user->phone, $otp);

            $token = $user->createToken($request->device_name ?? 'mobile-app')->plainTextToken;

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Inscription pharmacie réussie. Veuillez vérifier votre compte. En attente d\'approbation.',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'role' => $user->role,
                    ],
                    'pharmacy' => [
                        'id' => $pharmacy->id,
                        'name' => $pharmacy->name,
                        'status' => $pharmacy->status,
                    ],
                    'token' => $token,
                ],
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
}

