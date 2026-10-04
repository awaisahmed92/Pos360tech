<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class BankAccount extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'name', 'account_title', 'account_number', 'opening_balance', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'opening_balance' => 'decimal:2',
            'is_active' => 'boolean',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'name' => $this->name,
            'account_title' => $this->account_title,
            'account_number' => $this->account_number,
            'opening_balance' => $this->opening_balance,
            'is_active' => $this->is_active,
        ] + $this->timestampPayload();
    }
}
