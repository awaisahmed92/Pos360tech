<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Company extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'name',
        'company_code',
        'master_tenant_id',
        'currency_code',
        'currency_symbol',
        'subscription_status',
        'trial_ends_at',
    ];

    protected function casts(): array
    {
        return [
            'trial_ends_at' => 'datetime',
        ];
    }

    public function branches(): HasMany
    {
        return $this->hasMany(Branch::class);
    }

    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'company_code' => $this->company_code,
            'master_tenant_id' => $this->master_tenant_id,
            'currency_code' => $this->currency_code,
            'currency_symbol' => $this->currency_symbol,
            'subscription_status' => $this->subscription_status,
            'trial_ends_at' => optional($this->trial_ends_at)->toJSON(),
        ] + $this->timestampPayload();
    }
}
