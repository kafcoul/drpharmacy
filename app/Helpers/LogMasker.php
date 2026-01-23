<?php

namespace App\Helpers;

/**
 * Helper pour masquer les données personnelles identifiables (PII) dans les logs.
 * 
 * Usage:
 *   use App\Helpers\LogMasker;
 *   Log::info('User action', LogMasker::mask(['phone' => $user->phone, 'email' => $user->email]));
 */
class LogMasker
{
    /**
     * Champs à masquer automatiquement
     */
    private static array $sensitiveFields = [
        'phone',
        'email',
        'password',
        'token',
        'secret',
        'api_key',
        'card_number',
        'cvv',
        'pin',
        'otp',
        'verification_code',
    ];

    /**
     * Masquer les données sensibles dans un tableau
     * 
     * @param array $data
     * @return array
     */
    public static function mask(array $data): array
    {
        $masked = [];

        foreach ($data as $key => $value) {
            if (is_array($value)) {
                $masked[$key] = self::mask($value);
            } elseif (self::isSensitiveField($key)) {
                $masked[$key] = self::maskValue($value, $key);
            } else {
                $masked[$key] = $value;
            }
        }

        return $masked;
    }

    /**
     * Vérifier si un champ est sensible
     */
    private static function isSensitiveField(string $key): bool
    {
        $keyLower = strtolower($key);
        
        foreach (self::$sensitiveFields as $field) {
            if (str_contains($keyLower, $field)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Masquer une valeur selon son type
     */
    private static function maskValue(mixed $value, string $key): string
    {
        if ($value === null) {
            return '[null]';
        }

        $value = (string) $value;
        $length = strlen($value);

        if ($length === 0) {
            return '[empty]';
        }

        // Masquage spécifique par type de donnée
        $keyLower = strtolower($key);

        // Email: garder le début avant @
        if (str_contains($keyLower, 'email')) {
            return self::maskEmail($value);
        }

        // Téléphone: garder les 4 premiers et 2 derniers chiffres
        if (str_contains($keyLower, 'phone')) {
            return self::maskPhone($value);
        }

        // Token/Secret: montrer seulement les 4 premiers caractères
        if (str_contains($keyLower, 'token') || str_contains($keyLower, 'secret') || str_contains($keyLower, 'api_key')) {
            return self::maskToken($value);
        }

        // Par défaut: masquer tout sauf les 2 premiers et 2 derniers
        return self::maskGeneric($value);
    }

    /**
     * Masquer un email
     * exemple@domaine.com → exe***@dom***.com
     */
    public static function maskEmail(string $email): string
    {
        if (!str_contains($email, '@')) {
            return self::maskGeneric($email);
        }

        [$local, $domain] = explode('@', $email, 2);
        
        $maskedLocal = strlen($local) > 3 
            ? substr($local, 0, 3) . '***' 
            : $local[0] . '***';

        $domainParts = explode('.', $domain);
        $maskedDomain = strlen($domainParts[0]) > 3 
            ? substr($domainParts[0], 0, 3) . '***' 
            : $domainParts[0][0] . '***';

        $tld = count($domainParts) > 1 ? '.' . end($domainParts) : '';

        return "{$maskedLocal}@{$maskedDomain}{$tld}";
    }

    /**
     * Masquer un numéro de téléphone
     * +22507123456 → +2250***3456
     */
    public static function maskPhone(string $phone): string
    {
        $phone = preg_replace('/\s+/', '', $phone);
        $length = strlen($phone);

        if ($length <= 4) {
            return '****';
        }

        // Garder le préfixe (4-5 chars) et les 4 derniers chiffres
        $prefixLength = $phone[0] === '+' ? 5 : 4;
        $prefix = substr($phone, 0, min($prefixLength, $length - 4));
        $suffix = substr($phone, -4);
        
        return $prefix . '****' . $suffix;
    }

    /**
     * Masquer un token
     * abc123xyz789 → abc1****
     */
    public static function maskToken(string $token): string
    {
        $length = strlen($token);

        if ($length <= 4) {
            return '****';
        }

        return substr($token, 0, 4) . '****';
    }

    /**
     * Masquage générique
     */
    public static function maskGeneric(string $value): string
    {
        $length = strlen($value);

        if ($length <= 4) {
            return '****';
        }

        if ($length <= 8) {
            return substr($value, 0, 2) . '****';
        }

        return substr($value, 0, 2) . '****' . substr($value, -2);
    }

    /**
     * Logger avec masquage automatique des données sensibles
     * 
     * @param string $level info, warning, error, debug
     * @param string $message
     * @param array $context
     */
    public static function log(string $level, string $message, array $context = []): void
    {
        $maskedContext = self::mask($context);
        
        match ($level) {
            'debug' => \Log::debug($message, $maskedContext),
            'warning' => \Log::warning($message, $maskedContext),
            'error' => \Log::error($message, $maskedContext),
            default => \Log::info($message, $maskedContext),
        };
    }
}
