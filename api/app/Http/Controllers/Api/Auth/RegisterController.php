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

        // Send OTP with email as fallback
        $otp = $this->otpService->generateOtp($user->phone); // Prefer phone for mobile apps
        $channel = $this->otpService->sendOtp($user->phone, $otp, 'verification', $user->email);

        // Create token
        $token = $user->createToken($request->device_name ?? 'mobile-app')->plainTextToken;

        // Determine verification message
        $verificationMessage = match($channel) {
            'sms' => 'Un code de vérification a été envoyé par SMS.',
            'sms_fallback_email' => 'SMS indisponible, un code a été envoyé à votre email.',
            default => 'Un code de vérification vous a été envoyé.',
        };

        return response()->json([
            'success' => true,
            'message' => 'Inscription réussie. ' . $verificationMessage,
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
                'otp_channel' => $channel,
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

            // Send OTP for phone verification with email fallback
            $otp = $this->otpService->generateOtp($user->phone);
            $channel = $this->otpService->sendOtp($user->phone, $otp, 'verification', $user->email);

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
            'pharmacy_email' => 'nullable|string|email|max:255', // Email spécifique pour la pharmacie
            'pharmacy_phone' => 'nullable|string|max:20', // Téléphone spécifique pour la pharmacie
            'pharmacy_address' => 'required|string',
            'city' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'device_name' => 'string',
        ]);

        // Déterminer l'email et téléphone de la pharmacie
        $pharmacyEmail = strtolower(trim($validated['pharmacy_email'] ?? $validated['email']));
        $pharmacyPhone = $validated['pharmacy_phone'] ?? $validated['phone'];

        // Vérifier l'unicité dans la table pharmacies
        $existingPharmacy = \App\Models\Pharmacy::where('email', $pharmacyEmail)
            ->orWhere('phone', $pharmacyPhone)
            ->first();

        if ($existingPharmacy) {
            $conflicts = [];
            if ($existingPharmacy->email === $pharmacyEmail) {
                $conflicts['pharmacy_email'] = ['Cet email est déjà utilisé par une autre pharmacie.'];
            }
            if ($existingPharmacy->phone === $pharmacyPhone) {
                $conflicts['pharmacy_phone'] = ['Ce téléphone est déjà utilisé par une autre pharmacie.'];
            }
            return response()->json([
                'success' => false,
                'message' => 'Une pharmacie existe déjà avec cet email ou téléphone.',
                'errors' => $conflicts,
            ], 422);
        }

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

            // Create pharmacy avec email/phone potentiellement différents
            $pharmacy = \App\Models\Pharmacy::create([
                'name' => $validated['pharmacy_name'],
                'phone' => $pharmacyPhone,
                'email' => $pharmacyEmail,
                'address' => $validated['pharmacy_address'],
                'city' => $validated['city'],
                'license_number' => $validated['pharmacy_license'],
                'owner_name' => $validated['name'],
                'latitude' => $validated['latitude'] ?? null,
                'longitude' => $validated['longitude'] ?? null,
                'status' => 'pending',
            ]);

            // Attach user to pharmacy
            $pharmacy->users()->attach($user->id, ['role' => 'owner']);

            // Send OTP with email fallback
            $otp = $this->otpService->generateOtp($user->phone);
            $channel = $this->otpService->sendOtp($user->phone, $otp, 'verification', $user->email);

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
                        'phone' => $user->phone,
                        'role' => $user->role,
                        'pharmacies' => [
                            [
                                'id' => $pharmacy->id,
                                'name' => $pharmacy->name,
                                'address' => $pharmacy->address,
                                'city' => $pharmacy->city,
                                'phone' => $pharmacy->phone,
                                'email' => $pharmacy->email,
                                'status' => $pharmacy->status,
                                'license_number' => $pharmacy->license_number,
                            ]
                        ],
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

