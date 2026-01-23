<?php

namespace App\Models;

use App\Enums\JekoPaymentMethod;
use App\Enums\JekoPaymentStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class JekoPayment extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'uuid',
        'reference',
        'jeko_payment_request_id',
        'payable_type',
        'payable_id',
        'user_id',
        'amount_cents',
        'currency',
        'payment_method',
        'status',
        'redirect_url',
        'success_url',
        'error_url',
        'transaction_data',
        'error_message',
        'initiated_at',
        'completed_at',
        'webhook_received_at',
        'webhook_processed',
    ];

    protected $casts = [
        'status' => JekoPaymentStatus::class,
        'payment_method' => JekoPaymentMethod::class,
        'transaction_data' => 'array',
        'amount_cents' => 'integer',
        'webhook_processed' => 'boolean',
        'initiated_at' => 'datetime',
        'completed_at' => 'datetime',
        'webhook_received_at' => 'datetime',
    ];

    protected $hidden = [
        'transaction_data',
    ];

    /**
     * Boot the model
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($payment) {
            if (empty($payment->uuid)) {
                $payment->uuid = (string) Str::uuid();
            }
            if (empty($payment->reference)) {
                $payment->reference = self::generateReference();
            }
        });
    }

    /**
     * Générer une référence unique sécurisée
     * 
     * SECURITY V-002: Utilisation de 128 bits d'entropie (16 bytes = 32 hex chars)
     * Format: JEKO-{32 caractères hexadécimaux aléatoires cryptographiquement sûrs}
     */
    public static function generateReference(): string
    {
        return 'JEKO-' . bin2hex(random_bytes(16));
    }

    /**
     * Relation polymorphique vers l'entité payable (Order, WalletTopup, etc.)
     */
    public function payable(): MorphTo
    {
        return $this->morphTo();
    }

    /**
     * Relation vers l'utilisateur
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Montant en unité monétaire (pas en centimes)
     */
    public function getAmountAttribute(): float
    {
        return $this->amount_cents / 100;
    }

    /**
     * Montant formaté
     */
    public function getFormattedAmountAttribute(): string
    {
        return number_format($this->amount, 0, ',', ' ') . ' ' . $this->currency;
    }

    /**
     * Vérifier si le paiement est en attente
     */
    public function isPending(): bool
    {
        return $this->status === JekoPaymentStatus::PENDING;
    }

    /**
     * Vérifier si le paiement est réussi
     */
    public function isSuccess(): bool
    {
        return $this->status === JekoPaymentStatus::SUCCESS;
    }

    /**
     * Vérifier si le paiement a échoué
     */
    public function isFailed(): bool
    {
        return in_array($this->status, [JekoPaymentStatus::FAILED, JekoPaymentStatus::EXPIRED]);
    }

    /**
     * Vérifier si le paiement est finalisé
     */
    public function isFinal(): bool
    {
        return $this->status->isFinal();
    }

    /**
     * SECURITY V-010: Machine à états - Vérifier si une transition est autorisée
     * 
     * Règles:
     * - pending -> processing, failed, expired
     * - processing -> success, failed, expired
     * - success -> AUCUNE (état final)
     * - failed -> AUCUNE (état final)
     * - expired -> AUCUNE (état final)
     */
    public function canTransitionTo(JekoPaymentStatus $newStatus): bool
    {
        $allowedTransitions = [
            JekoPaymentStatus::PENDING->value => [
                JekoPaymentStatus::PROCESSING,
                JekoPaymentStatus::FAILED,
                JekoPaymentStatus::EXPIRED,
            ],
            JekoPaymentStatus::PROCESSING->value => [
                JekoPaymentStatus::SUCCESS,
                JekoPaymentStatus::FAILED,
                JekoPaymentStatus::EXPIRED,
            ],
            JekoPaymentStatus::SUCCESS->value => [], // État final
            JekoPaymentStatus::FAILED->value => [],  // État final
            JekoPaymentStatus::EXPIRED->value => [], // État final
        ];

        $allowed = $allowedTransitions[$this->status->value] ?? [];
        
        return in_array($newStatus, $allowed);
    }

    /**
     * SECURITY V-010: Transition sécurisée vers un nouveau statut
     * 
     * @throws \InvalidArgumentException si la transition n'est pas autorisée
     */
    public function transitionTo(JekoPaymentStatus $newStatus): bool
    {
        if (!$this->canTransitionTo($newStatus)) {
            \Illuminate\Support\Facades\Log::warning('JEKO Payment: Transition de statut non autorisée', [
                'reference' => $this->reference,
                'current_status' => $this->status->value,
                'requested_status' => $newStatus->value,
            ]);
            return false;
        }

        return true;
    }

    /**
     * Marquer comme succès
     */
    public function markAsSuccess(array $transactionData = []): self
    {
        // SECURITY V-010: Vérifier la transition
        if (!$this->transitionTo(JekoPaymentStatus::SUCCESS)) {
            return $this;
        }

        $this->update([
            'status' => JekoPaymentStatus::SUCCESS,
            'transaction_data' => $transactionData,
            'completed_at' => now(),
            'webhook_processed' => true,
            'webhook_received_at' => now(),
        ]);

        return $this;
    }

    /**
     * Marquer comme échec
     */
    public function markAsFailed(?string $errorMessage = null): self
    {
        // SECURITY V-010: Vérifier la transition
        if (!$this->transitionTo(JekoPaymentStatus::FAILED)) {
            return $this;
        }

        $this->update([
            'status' => JekoPaymentStatus::FAILED,
            'error_message' => $errorMessage,
            'completed_at' => now(),
            'webhook_processed' => true,
            'webhook_received_at' => now(),
        ]);

        return $this;
    }

    /**
     * Marquer comme expiré
     */
    public function markAsExpired(): self
    {
        // SECURITY V-010: Vérifier la transition
        if (!$this->transitionTo(JekoPaymentStatus::EXPIRED)) {
            return $this;
        }

        $this->update([
            'status' => JekoPaymentStatus::EXPIRED,
            'error_message' => 'Payment timeout - no response received',
            'completed_at' => now(),
        ]);

        return $this;
    }

    /**
     * Scope: Paiements en attente
     */
    public function scopePending($query)
    {
        return $query->where('status', JekoPaymentStatus::PENDING);
    }

    /**
     * Scope: Paiements expirés (pending > 5 min sans webhook)
     */
    public function scopeExpiredPending($query, int $minutes = 5)
    {
        return $query->where('status', JekoPaymentStatus::PENDING)
            ->where('initiated_at', '<', now()->subMinutes($minutes))
            ->where('webhook_processed', false);
    }

    /**
     * Scope: Par référence
     */
    public function scopeByReference($query, string $reference)
    {
        return $query->where('reference', $reference);
    }

    /**
     * Scope: Par ID JEKO
     */
    public function scopeByJekoId($query, string $jekoId)
    {
        return $query->where('jeko_payment_request_id', $jekoId);
    }
}
