<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PrescriptionResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            'source' => $this->source ?? 'upload',
            'notes' => $this->notes,
            // The 'images' attribute is automatically transformed by the Model Accessor to absolute URLs
            'images' => $this->images, 
            'quote_amount' => $this->quote_amount,
            'pharmacy_notes' => $this->pharmacy_notes,
            'admin_notes' => $this->when($request->user()->id === $this->validated_by || $request->user()->role === 'admin' || $request->user()->role === 'pharmacy', $this->admin_notes),
            'customer_id' => $this->customer_id,
            'created_at' => $this->created_at,
            'validated_at' => $this->validated_at,
            'validated_by' => $this->validated_by,
            'order' => $this->whenLoaded('order', function () {
                return [
                    'id' => $this->order->id,
                    'reference' => $this->order->reference,
                    'status' => $this->order->status,
                ];
            }),
            'customer' => $this->whenLoaded('customer', function () {
                return [
                    'id' => $this->customer->id,
                    'name' => $this->customer->name,
                    'email' => $this->customer->email,
                    'phone' => $this->customer->phone,
                ];
            }),
        ];
    }
}
