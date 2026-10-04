<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class LedgerAccount extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'code', 'name_en', 'name_ur', 'type',
        'parent_client_uuid', 'opening_balance', 'description', 'is_active', 'is_system',
    ];

    protected function casts(): array
    {
        return [
            'opening_balance' => 'decimal:2',
            'is_active' => 'boolean',
            'is_system' => 'boolean',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'code' => $this->code,
            'name_en' => $this->name_en,
            'name_ur' => $this->name_ur,
            'type' => $this->type,
            'parent_client_uuid' => $this->parent_client_uuid,
            'opening_balance' => $this->opening_balance,
            'description' => $this->description,
            'is_active' => $this->is_active,
            'is_system' => $this->is_system,
        ] + $this->timestampPayload();
    }
}
