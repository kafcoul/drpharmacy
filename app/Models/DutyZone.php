<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class DutyZone extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'city',
        'description',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function onCalls(): HasMany
    {
        return $this->hasMany(PharmacyOnCall::class);
    }
}
