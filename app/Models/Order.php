<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Order extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'reference',
        'pharmacy_id',
        'customer_id',
        'status',
        'delivery_code',
        'payment_mode',
        'subtotal',
        'delivery_fee',
        'total_amount',
        'currency',
        'customer_notes',
        'pharmacy_notes',
        'prescription_image',
        'delivery_address',
        'delivery_city',
        'delivery_latitude',
        'delivery_longitude',
        'customer_phone',
        'confirmed_at',
        'paid_at',
        'delivered_at',
        'cancelled_at',
        'cancellation_reason',
    ];

    protected $casts = [
        'subtotal' => 'decimal:2',
        'delivery_fee' => 'decimal:2',
        'total_amount' => 'decimal:2',
        'delivery_latitude' => 'decimal:7',
        'delivery_longitude' => 'decimal:7',
        'confirmed_at' => 'datetime',
        'paid_at' => 'datetime',
        'delivered_at' => 'datetime',
        'cancelled_at' => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($order) {
            if (empty($order->delivery_code)) {
                $order->delivery_code = str_pad(mt_rand(0, 9999), 4, '0', STR_PAD_LEFT);
            }
        });
    }

    /**
     * Pharmacie
     */
    public function pharmacy(): BelongsTo
    {
        return $this->belongsTo(Pharmacy::class);
    }

    /**
     * Client
     */
    public function customer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    /**
     * Articles de la commande
     */
    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    /**
     * Livraison
     */
    public function delivery(): HasOne
    {
        return $this->hasOne(Delivery::class);
    }

    /**
     * Intentions de paiement
     */
    public function paymentIntents(): HasMany
    {
        return $this->hasMany(PaymentIntent::class);
    }

    /**
     * Paiements confirmés
     */
    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    /**
     * Commission
     */
    public function commission(): HasOne
    {
        return $this->hasOne(Commission::class);
    }

    /**
     * Générer une référence unique
     */
    public static function generateReference(): string
    {
        return 'DR-' . strtoupper(uniqid());
    }

    /**
     * Scope: commandes payées
     */
    public function scopePaid($query)
    {
        return $query->whereIn('status', [
            'confirmed', 'preparing', 'ready_for_pickup', 'on_the_way', 'delivered'
        ]);
    }

    /**
     * Scope: commandes d'une pharmacie
     */
    public function scopeForPharmacy($query, int $pharmacyId)
    {
        return $query->where('pharmacy_id', $pharmacyId);
    }

    /**
     * Vérifier si la commande est payée
     */
    public function isPaid(): bool
    {
        return in_array($this->status, [
            'confirmed', 'preparing', 'ready_for_pickup', 'on_the_way', 'delivered'
        ]);
    }
}

