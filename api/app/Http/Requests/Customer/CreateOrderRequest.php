<?php

namespace App\Http\Requests\Customer;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

/**
 * Form Request pour la création de commande
 * 
 * Security Audit Week 2 - Validation centralisée
 */
class CreateOrderRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // L'utilisateur doit être authentifié (géré par le middleware)
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'pharmacy_id' => 'required|exists:pharmacies,id',
            'items' => 'required|array|min:1|max:50',
            'items.*.id' => 'nullable|exists:products,id',
            'items.*.name' => 'required|string|max:255',
            'items.*.quantity' => 'required|integer|min:1|max:99',
            'items.*.price' => 'required|numeric|min:0|max:9999999',
            'prescription_image' => 'nullable|string|max:500',
            'customer_notes' => 'nullable|string|max:1000',
            'delivery_address' => 'required|string|max:500',
            'delivery_city' => 'nullable|string|max:100',
            'delivery_latitude' => 'nullable|numeric|between:-90,90',
            'delivery_longitude' => 'nullable|numeric|between:-180,180',
            'customer_phone' => [
                'required',
                'string',
                'regex:/^(\+?[0-9]{8,15})$/',
            ],
            'payment_mode' => 'required|in:cash,mobile_money,card',
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'pharmacy_id.required' => 'La pharmacie est requise.',
            'pharmacy_id.exists' => 'La pharmacie sélectionnée n\'existe pas.',
            'items.required' => 'La commande doit contenir au moins un article.',
            'items.min' => 'La commande doit contenir au moins un article.',
            'items.max' => 'La commande ne peut pas contenir plus de 50 articles.',
            'items.*.name.required' => 'Le nom du produit est requis.',
            'items.*.quantity.required' => 'La quantité est requise.',
            'items.*.quantity.min' => 'La quantité doit être d\'au moins 1.',
            'items.*.quantity.max' => 'La quantité ne peut pas dépasser 99.',
            'items.*.price.required' => 'Le prix est requis.',
            'items.*.price.min' => 'Le prix ne peut pas être négatif.',
            'delivery_address.required' => 'L\'adresse de livraison est requise.',
            'delivery_address.max' => 'L\'adresse est trop longue.',
            'customer_phone.required' => 'Le numéro de téléphone est requis.',
            'customer_phone.regex' => 'Le format du numéro de téléphone est invalide.',
            'payment_mode.required' => 'Le mode de paiement est requis.',
            'payment_mode.in' => 'Mode de paiement invalide.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     *
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'pharmacy_id' => 'pharmacie',
            'items' => 'articles',
            'delivery_address' => 'adresse de livraison',
            'customer_phone' => 'téléphone',
            'payment_mode' => 'mode de paiement',
        ];
    }

    /**
     * Handle a failed validation attempt.
     *
     * @throws HttpResponseException
     */
    protected function failedValidation(Validator $validator): void
    {
        throw new HttpResponseException(
            response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422)
        );
    }

    /**
     * Prepare the data for validation.
     */
    protected function prepareForValidation(): void
    {
        // Nettoyer le numéro de téléphone
        if ($this->has('customer_phone')) {
            $phone = preg_replace('/[^0-9+]/', '', $this->customer_phone);
            $this->merge(['customer_phone' => $phone]);
        }

        // Trim les strings
        if ($this->has('delivery_address')) {
            $this->merge(['delivery_address' => trim($this->delivery_address)]);
        }
        if ($this->has('customer_notes')) {
            $this->merge(['customer_notes' => trim($this->customer_notes)]);
        }
    }
}
