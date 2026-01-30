<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Casts\Attribute;

class Prescription extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'images',
        'notes',
        'status',
        'admin_notes',
        'validated_at',
        'validated_by',
    ];

    protected $casts = [
        'validated_at' => 'datetime',
    ];

    /**
     * Get the images attribute with absolute URLs.
     * Converts relative paths to full URLs via secure document endpoint.
     */
    protected function images(): Attribute
    {
        return Attribute::make(
            get: function ($value) {
                $images = is_string($value) ? json_decode($value, true) : $value;
                
                if (empty($images) || !is_array($images)) {
                    return [];
                }

                return array_map(function ($path) {
                    // If already an absolute URL, return as-is
                    if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
                        return $path;
                    }

                    // Build URL via secure document endpoint
                    // Path format: prescriptions/{user_id}/{filename}
                    return url('/api/documents/' . $path);
                }, $images);
            },
            set: function ($value) {
                return is_array($value) ? json_encode($value) : $value;
            }
        );
    }

    /**
     * Get raw images paths without URL transformation (for internal use).
     */
    public function getRawImages(): array
    {
        $value = $this->attributes['images'] ?? null;
        $images = is_string($value) ? json_decode($value, true) : $value;
        return is_array($images) ? $images : [];
    }

    /**
     * Prescription statuses
     */
    const STATUS_PENDING = 'pending';
    const STATUS_VALIDATED = 'validated';
    const STATUS_REJECTED = 'rejected';

    /**
     * Get the customer that owns the prescription
     */
    public function customer()
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    /**
     * Get the admin who validated the prescription
     */
    public function validator()
    {
        return $this->belongsTo(User::class, 'validated_by');
    }

    /**
     * Scope for pending prescriptions
     */
    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    /**
     * Scope for validated prescriptions
     */
    public function scopeValidated($query)
    {
        return $query->where('status', self::STATUS_VALIDATED);
    }

    /**
     * Check if prescription is pending
     */
    public function isPending(): bool
    {
        return $this->status === self::STATUS_PENDING;
    }

    /**
     * Check if prescription is validated
     */
    public function isValidated(): bool
    {
        return $this->status === self::STATUS_VALIDATED;
    }
}
