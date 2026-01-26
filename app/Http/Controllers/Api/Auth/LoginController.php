<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class LoginController extends Controller
{
    /**
     * Login user and create token
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required', // Allow email or phone
            'password' => 'required',
            'device_name' => 'string',
            'role' => 'nullable|string|in:customer,courier,pharmacy', // Rôle attendu par l'application
        ]);

        // Normaliser l'email en minuscules pour éviter les problèmes de case sensitivity
        $login = trim($request->email);
        
        // Check if login is email or phone
        $fieldType = filter_var($login, FILTER_VALIDATE_EMAIL) ? 'email' : 'phone';

        // Si c'est un email, le convertir en minuscules
        if ($fieldType === 'email') {
            $login = strtolower($login);
        }

        $user = null;
        if ($fieldType === 'phone') {
             $user = User::where(function($query) use ($login) {
                 $query->where('phone', $login)
                       ->orWhere('phone', '+' . ltrim($login, '+'))
                       ->orWhere('phone', ltrim($login, '+'));
             })->first();
        } else {
             $user = User::where('email', $login)->first();
        }

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Les identifiants fournis sont incorrects.'],
            ]);
        }

        // Vérifier que le rôle de l'utilisateur correspond à l'application
        $expectedRole = $request->role;
        if ($expectedRole) {
            if ($expectedRole === 'courier' && $user->role !== 'courier') {
                throw ValidationException::withMessages([
                    'email' => ['Ce compte n\'est pas un compte livreur. Veuillez utiliser l\'application client.'],
                ]);
            }
            if ($expectedRole === 'pharmacy' && $user->role !== 'pharmacy') {
                throw ValidationException::withMessages([
                    'email' => ['Ce compte n\'est pas un compte pharmacie. Veuillez utiliser l\'application appropriée.'],
                ]);
            }
            if ($expectedRole === 'customer' && $user->role !== 'customer') {
                throw ValidationException::withMessages([
                    'email' => ['Ce compte n\'est pas un compte client. Veuillez utiliser l\'application appropriée.'],
                ]);
            }
        }

        // Vérifier le statut d'approbation pour les coursiers
        if ($user->role === 'courier') {
            $courier = $user->courier;
            if ($courier) {
                if ($courier->status === 'pending_approval') {
                    throw ValidationException::withMessages([
                        'email' => ['Votre compte est en attente d\'approbation par l\'administrateur. Vous recevrez une notification une fois approuvé.'],
                    ]);
                }
                if ($courier->status === 'suspended') {
                    throw ValidationException::withMessages([
                        'email' => ['Votre compte a été suspendu. Veuillez contacter le support.'],
                    ]);
                }
                if ($courier->status === 'rejected') {
                    throw ValidationException::withMessages([
                        'email' => ['Votre demande d\'inscription a été refusée. Veuillez contacter le support pour plus d\'informations.'],
                    ]);
                }
            }
        }

        // Vérifier le statut d'approbation pour les pharmacies
        if ($user->role === 'pharmacy') {
            $pharmacy = $user->pharmacies()->first();
            if ($pharmacy && $pharmacy->status === 'pending') {
                throw ValidationException::withMessages([
                    'email' => ['Votre pharmacie est en attente d\'approbation par l\'administrateur.'],
                ]);
            }
            if ($pharmacy && $pharmacy->status === 'suspended') {
                throw ValidationException::withMessages([
                    'email' => ['Votre pharmacie a été suspendue. Veuillez contacter le support.'],
                ]);
            }
            if ($pharmacy && $pharmacy->status === 'rejected') {
                throw ValidationException::withMessages([
                    'email' => ['Votre demande d\'inscription a été refusée.'],
                ]);
            }
        }

        // Create token
        $token = $user->createToken($request->device_name ?? 'mobile-app')->plainTextToken;

        // Prepare user data
        $userData = [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'role' => $user->role,
            'avatar' => $user->avatar,
        ];

        if ($user->role === 'pharmacy') {
            $userData['pharmacies'] = $user->pharmacies;
        }
        
        // Ajouter le statut du coursier dans la réponse
        if ($user->role === 'courier' && $user->courier) {
            $userData['courier_status'] = $user->courier->status;
        }

        return response()->json([
            'success' => true,
            'message' => 'Connexion réussie',
            'data' => [
                'user' => $userData,
                'token' => $token,
            ],
        ]);
    }

    /**
     * Logout user (revoke token)
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Déconnexion réussie',
        ]);
    }

    /**
     * Get authenticated user
     */
    public function me(Request $request)
    {
        $user = $request->user();
        $data = [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'role' => $user->role,
            'avatar' => $user->avatar,
            'created_at' => $user->created_at,
        ];

        if ($user->role === 'customer') {
            // Customer specific data if any
        } elseif ($user->role === 'pharmacy') {
            $data['pharmacies'] = $user->pharmacies;
            // Wallet is usually attached to Pharmacy, not User in this case, or maybe User has wallet?
            // If User has wallet:
            $data['wallet'] = $user->wallet; 
        } elseif ($user->role === 'courier') {
            $data['courier'] = $user->courier;
            $data['wallet'] = $user->courier?->wallet;
        }

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Update authenticated user profile
     */
    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:20|unique:users,phone,' . $request->user()->id,
        ]);

        $user = $request->user();
        
        $data = [];
        if ($request->has('name') && $request->name) {
            $data['name'] = $request->name;
        }
        if ($request->has('phone') && $request->phone) {
            $data['phone'] = $request->phone;
        }
        
        if (empty($data)) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune donnée à mettre à jour',
            ], 400);
        }
        
        $user->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Profil mis à jour avec succès',
            'data' => $user,
        ]);
    }
}

