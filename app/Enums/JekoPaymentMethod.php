<?php

namespace App\Enums;

enum JekoPaymentMethod: string
{
    case WAVE = 'wave';
    case ORANGE = 'orange';
    case MTN = 'mtn';
    case MOOV = 'moov';
    case DJAMO = 'djamo';

    public function label(): string
    {
        return match ($this) {
            self::WAVE => 'Wave',
            self::ORANGE => 'Orange Money',
            self::MTN => 'MTN Mobile Money',
            self::MOOV => 'Moov Money',
            self::DJAMO => 'Djamo',
        };
    }

    public function icon(): string
    {
        return match ($this) {
            self::WAVE => 'wave',
            self::ORANGE => 'orange-money',
            self::MTN => 'mtn-momo',
            self::MOOV => 'moov-money',
            self::DJAMO => 'djamo',
        };
    }

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
