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
        ]);

        $login = $request->email;
        
        // Check if login is email or phone
        $fieldType = filter_var($login, FILTER_VALIDATE_EMAIL) ? 'email' : 'phone';

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
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:20',
        ]);

        $user = $request->user();
        $user->update([
            'name' => $request->name,
            'phone' => $request->phone,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Profil mis à jour avec succès',
            'data' => $user,
        ]);
    }
}

