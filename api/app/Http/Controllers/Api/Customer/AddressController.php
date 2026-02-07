<?php

namespace App\Http\Controllers\Api\Customer;

use App\Http\Controllers\Controller;
use App\Models\CustomerAddress;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class AddressController extends Controller
{
    /**
     * Liste toutes les adresses du client
     */
    public function index(): JsonResponse
    {
        $addresses = Auth::user()->addresses()
            ->orderBy('is_default', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $addresses->map(fn($address) => $this->formatAddress($address)),
        ]);
    }

    /**
     * Récupérer une adresse spécifique
     */
    public function show(int $id): JsonResponse
    {
        $address = Auth::user()->addresses()->find($id);

        if (!$address) {
            return response()->json([
                'status' => 'error',
                'message' => 'Adresse non trouvée',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $this->formatAddress($address),
        ]);
    }

    /**
     * Créer une nouvelle adresse
     */
    public function store(Request $request): JsonResponse
    {
        // Normaliser le label (première lettre majuscule) pour accepter "maison", "MAISON", "Maison"
        if ($request->has('label')) {
            $request->merge(['label' => ucfirst(strtolower($request->input('label')))]);
        }

        $validated = $request->validate([
            'label' => ['required', 'string', 'max:50', Rule::in(CustomerAddress::LABELS)],
            'address' => 'required|string|max:255',
            'city' => 'nullable|string|max:100',
            'district' => 'nullable|string|max:100',
            'phone' => 'nullable|string|max:20',
            'instructions' => 'nullable|string|max:500',
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'is_default' => 'boolean',
        ]);

        $user = Auth::user();
        
        // Utiliser le téléphone du profil si non fourni
        if (empty($validated['phone']) && $user->phone) {
            $validated['phone'] = $user->phone;
        }
        
        // Si c'est la première adresse ou si elle doit être par défaut
        $isDefault = $validated['is_default'] ?? false;
        $isFirstAddress = $user->addresses()->count() === 0;
        
        if ($isFirstAddress) {
            $isDefault = true;
        }

        // Si cette adresse est par défaut, retirer le flag des autres
        if ($isDefault) {
            $user->addresses()->update(['is_default' => false]);
        }

        $address = $user->addresses()->create([
            ...$validated,
            'is_default' => $isDefault,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Adresse créée avec succès',
            'data' => $this->formatAddress($address),
        ], 201);
    }

    /**
     * Mettre à jour une adresse
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $address = Auth::user()->addresses()->find($id);

        if (!$address) {
            return response()->json([
                'status' => 'error',
                'message' => 'Adresse non trouvée',
            ], 404);
        }

        // Normaliser le label (première lettre majuscule) pour accepter "maison", "MAISON", "Maison"
        if ($request->has('label')) {
            $request->merge(['label' => ucfirst(strtolower($request->input('label')))]);
        }

        $validated = $request->validate([
            'label' => ['nullable', 'string', 'max:50', Rule::in(CustomerAddress::LABELS)],
            'address' => 'nullable|string|max:255',
            'city' => 'nullable|string|max:100',
            'district' => 'nullable|string|max:100',
            'phone' => 'nullable|string|max:20',
            'instructions' => 'nullable|string|max:500',
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'is_default' => 'boolean',
        ]);

        // Si cette adresse devient par défaut
        if (isset($validated['is_default']) && $validated['is_default']) {
            Auth::user()->addresses()
                ->where('id', '!=', $id)
                ->update(['is_default' => false]);
        }

        $address->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Adresse mise à jour avec succès',
            'data' => $this->formatAddress($address->fresh()),
        ]);
    }

    /**
     * Supprimer une adresse
     */
    public function destroy(int $id): JsonResponse
    {
        $user = Auth::user();
        $address = $user->addresses()->find($id);

        if (!$address) {
            return response()->json([
                'status' => 'error',
                'message' => 'Adresse non trouvée',
            ], 404);
        }

        $wasDefault = $address->is_default;
        $address->delete();

        // Si c'était l'adresse par défaut, définir une autre comme défaut
        if ($wasDefault) {
            $newDefault = $user->addresses()->first();
            if ($newDefault) {
                $newDefault->update(['is_default' => true]);
            }
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Adresse supprimée avec succès',
        ]);
    }

    /**
     * Définir une adresse comme adresse par défaut
     */
    public function setDefault(int $id): JsonResponse
    {
        $address = Auth::user()->addresses()->find($id);

        if (!$address) {
            return response()->json([
                'status' => 'error',
                'message' => 'Adresse non trouvée',
            ], 404);
        }

        $address->setAsDefault();

        return response()->json([
            'status' => 'success',
            'message' => 'Adresse définie comme adresse par défaut',
            'data' => $this->formatAddress($address->fresh()),
        ]);
    }

    /**
     * Obtenir l'adresse par défaut
     */
    public function getDefault(): JsonResponse
    {
        $address = Auth::user()->defaultAddress;

        if (!$address) {
            return response()->json([
                'status' => 'error',
                'message' => 'Aucune adresse par défaut',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $this->formatAddress($address),
        ]);
    }

    /**
     * Obtenir les labels disponibles
     */
    public function getLabels(): JsonResponse
    {
        $user = Auth::user();
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'labels' => CustomerAddress::LABELS,
                'default_phone' => $user->phone,
                'user_name' => $user->name,
            ],
        ]);
    }

    /**
     * Formater une adresse pour la réponse API
     */
    private function formatAddress(CustomerAddress $address): array
    {
        return [
            'id' => $address->id,
            'label' => $address->label,
            'address' => $address->address,
            'city' => $address->city,
            'district' => $address->district,
            'phone' => $address->phone,
            'instructions' => $address->instructions,
            'latitude' => $address->latitude,
            'longitude' => $address->longitude,
            'is_default' => $address->is_default,
            'full_address' => $address->full_address,
            'has_coordinates' => $address->hasCoordinates(),
            'created_at' => $address->created_at->toIso8601String(),
            'updated_at' => $address->updated_at->toIso8601String(),
        ];
    }
}
