<?php

namespace App\Enums;

enum JekoPaymentMethod: string
{
    // Côte d'Ivoire
    case WAVE = 'wave';
    case ORANGE_CI = 'orange_ci';
    case MTN_CI = 'mtn_ci';
    case MOOV_CI = 'moov_ci';
    
    // Autres
    case BANK_TRANSFER = 'bank_transfer';

    public function label(): string
    {
        return match ($this) {
            self::WAVE => 'Wave',
            self::ORANGE_CI => 'Orange Money',
            self::MTN_CI => 'MTN Mobile Money',
            self::MOOV_CI => 'Moov Money',
            self::BANK_TRANSFER => 'Virement Bancaire',
        };
    }

    public function icon(): string
    {
        return match ($this) {
            self::WAVE => 'wave',
            self::ORANGE_CI => 'orange-money',
            self::MTN_CI => 'mtn-momo',
            self::MOOV_CI => 'moov-money',
            self::BANK_TRANSFER => 'bank',
        };
    }

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
    
    /**
     * Méthodes disponibles pour les décaissements (payout) - Côte d'Ivoire
     */
    public static function payoutMethods(): array
    {
        return [
            self::ORANGE_CI,
            self::MTN_CI,
            self::MOOV_CI,
            self::WAVE,
            self::BANK_TRANSFER,
        ];
    }
    
    /**
     * Méthodes disponibles pour les paiements (encaissement) - Côte d'Ivoire
     */
    public static function paymentMethods(): array
    {
        return [
            self::ORANGE_CI,
            self::MTN_CI,
            self::MOOV_CI,
            self::WAVE,
        ];
    }
}
