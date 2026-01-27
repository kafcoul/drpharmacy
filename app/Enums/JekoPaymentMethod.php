<?php

namespace App\Enums;

enum JekoPaymentMethod: string
{
    case WAVE = 'wave';
    case ORANGE = 'orange';
    case MTN = 'mtn';
    case MOOV = 'moov';
    case DJAMO = 'djamo';
    case BANK_TRANSFER = 'bank_transfer';
    
    // Bénin specific
    case MTN_BJ = 'mtn_bj';
    case MOOV_BJ = 'moov_bj';

    public function label(): string
    {
        return match ($this) {
            self::WAVE => 'Wave',
            self::ORANGE => 'Orange Money',
            self::MTN => 'MTN Mobile Money',
            self::MOOV => 'Moov Money',
            self::DJAMO => 'Djamo',
            self::BANK_TRANSFER => 'Virement Bancaire',
            self::MTN_BJ => 'MTN Bénin',
            self::MOOV_BJ => 'Moov Bénin',
        };
    }

    public function icon(): string
    {
        return match ($this) {
            self::WAVE => 'wave',
            self::ORANGE => 'orange-money',
            self::MTN, self::MTN_BJ => 'mtn-momo',
            self::MOOV, self::MOOV_BJ => 'moov-money',
            self::DJAMO => 'djamo',
            self::BANK_TRANSFER => 'bank',
        };
    }

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
    
    /**
     * Méthodes disponibles pour les décaissements (payout)
     */
    public static function payoutMethods(): array
    {
        return [
            self::MTN_BJ,
            self::MOOV_BJ,
            self::WAVE,
            self::BANK_TRANSFER,
        ];
    }
}
