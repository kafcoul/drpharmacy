<?php

namespace App\Http\Requests\Customer;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

/**
 * Form Request pour le paiement d'une commande
 * 
 * Security Audit Week 2 - Validation centralisée
 */
class PaymentRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
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
            'payment_method' => 'required|in:mobile_money,card,cash',
            'phone_number' => [
                'required_if:payment_method,mobile_money',
                'nullable',
                'string',
                'regex:/^(\+?[0-9]{8,15})$/',
            ],
            'operator' => 'required_if:payment_method,mobile_money|in:mtn,orange,moov,wave',
            'callback_url' => 'nullable|url|max:500',
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
            'payment_method.required' => 'Le mode de paiement est requis.',
            'payment_method.in' => 'Mode de paiement invalide. Utilisez: mobile_money, card, ou cash.',
            'phone_number.required_if' => 'Le numéro de téléphone est requis pour le paiement Mobile Money.',
            'phone_number.regex' => 'Format de numéro de téléphone invalide.',
            'operator.required_if' => 'L\'opérateur est requis pour le paiement Mobile Money.',
            'operator.in' => 'Opérateur invalide. Utilisez: mtn, orange, moov, ou wave.',
            'callback_url.url' => 'L\'URL de callback est invalide.',
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
                'message' => 'Erreur de validation du paiement',
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
        if ($this->has('phone_number')) {
            $phone = preg_replace('/[^0-9+]/', '', $this->phone_number);
            $this->merge(['phone_number' => $phone]);
        }

        // Normaliser l'opérateur en lowercase
        if ($this->has('operator')) {
            $this->merge(['operator' => strtolower($this->operator)]);
        }
    }
}
