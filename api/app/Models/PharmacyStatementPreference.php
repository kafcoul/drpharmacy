<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Carbon\Carbon;

class PharmacyStatementPreference extends Model
{
    use HasFactory;

    protected $fillable = [
        'pharmacy_id',
        'frequency',
        'format',
        'auto_send',
        'email',
        'next_send_at',
        'last_sent_at',
    ];

    protected $casts = [
        'auto_send' => 'boolean',
        'next_send_at' => 'datetime',
        'last_sent_at' => 'datetime',
    ];

    /**
     * Relation avec la pharmacie
     */
    public function pharmacy(): BelongsTo
    {
        return $this->belongsTo(Pharmacy::class);
    }

    /**
     * Calcule la prochaine date d'envoi selon la fréquence
     */
    public function calculateNextSendDate(): Carbon
    {
        $now = Carbon::now();

        return match ($this->frequency) {
            'weekly' => $now->next(Carbon::MONDAY)->setTime(8, 0),
            'monthly' => $now->addMonth()->startOfMonth()->setTime(8, 0),
            'quarterly' => $now->addQuarter()->startOfQuarter()->setTime(8, 0),
            default => $now->addMonth()->startOfMonth()->setTime(8, 0),
        };
    }

    /**
     * Met à jour la date du prochain envoi
     */
    public function scheduleNextSend(): void
    {
        $this->update([
            'next_send_at' => $this->calculateNextSendDate(),
            'last_sent_at' => now(),
        ]);
    }

    /**
     * Retourne le label de fréquence en français
     */
    public function getFrequencyLabelAttribute(): string
    {
        return match ($this->frequency) {
            'weekly' => 'Hebdomadaire',
            'monthly' => 'Mensuel',
            'quarterly' => 'Trimestriel',
            default => 'Mensuel',
        };
    }

    /**
     * Retourne le label du format
     */
    public function getFormatLabelAttribute(): string
    {
        return strtoupper($this->format);
    }

    /**
     * Récupère l'email à utiliser (préférence ou email pharmacie)
     */
    public function getEffectiveEmailAttribute(): string
    {
        return $this->email ?? $this->pharmacy->email ?? $this->pharmacy->user?->email;
    }

    /**
     * Scope pour les relevés à envoyer maintenant
     */
    public function scopeDueForSending($query)
    {
        return $query->where('auto_send', true)
            ->where('next_send_at', '<=', now());
    }

    /**
     * Retourne la période couverte par le relevé selon la fréquence
     */
    public function getStatementPeriod(): array
    {
        $endDate = now();
        
        $startDate = match ($this->frequency) {
            'weekly' => $endDate->copy()->subWeek(),
            'monthly' => $endDate->copy()->subMonth(),
            'quarterly' => $endDate->copy()->subQuarter(),
            default => $endDate->copy()->subMonth(),
        };

        return [
            'start' => $startDate->startOfDay(),
            'end' => $endDate->endOfDay(),
        ];
    }
}
