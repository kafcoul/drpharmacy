<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DeliveryMessage extends Model
{
    use HasFactory;

    protected $fillable = [
        'delivery_id',
        'sender_type',
        'sender_id',
        'receiver_type',
        'receiver_id',
        'message',
        'read_at',
    ];

    protected $casts = [
        'read_at' => 'datetime',
    ];

    /**
     * Relation avec la livraison
     */
    public function delivery(): BelongsTo
    {
        return $this->belongsTo(Delivery::class);
    }

    /**
     * Récupérer l'expéditeur (courier, pharmacy ou client)
     */
    public function sender()
    {
        return match($this->sender_type) {
            'courier' => Courier::find($this->sender_id),
            'pharmacy' => Pharmacy::find($this->sender_id),
            'client' => User::find($this->sender_id),
            default => null,
        };
    }

    /**
     * Récupérer le destinataire (courier, pharmacy ou client)
     */
    public function receiver()
    {
        return match($this->receiver_type) {
            'courier' => Courier::find($this->receiver_id),
            'pharmacy' => Pharmacy::find($this->receiver_id),
            'client' => User::find($this->receiver_id),
            default => null,
        };
    }

    /**
     * Marquer comme lu
     */
    public function markAsRead(): void
    {
        if (!$this->read_at) {
            $this->update(['read_at' => now()]);
        }
    }

    /**
     * Vérifier si le message est lu
     */
    public function isRead(): bool
    {
        return $this->read_at !== null;
    }

    /**
     * Scope pour les messages non lus
     */
    public function scopeUnread($query)
    {
        return $query->whereNull('read_at');
    }

    /**
     * Scope pour les messages d'une conversation
     */
    public function scopeForConversation($query, int $deliveryId, string $type1, int $id1, string $type2, int $id2)
    {
        return $query->where('delivery_id', $deliveryId)
            ->where(function ($q) use ($type1, $id1, $type2, $id2) {
                $q->where(function ($q2) use ($type1, $id1, $type2, $id2) {
                    $q2->where('sender_type', $type1)
                       ->where('sender_id', $id1)
                       ->where('receiver_type', $type2)
                       ->where('receiver_id', $id2);
                })->orWhere(function ($q2) use ($type1, $id1, $type2, $id2) {
                    $q2->where('sender_type', $type2)
                       ->where('sender_id', $id2)
                       ->where('receiver_type', $type1)
                       ->where('receiver_id', $id1);
                });
            });
    }
}
