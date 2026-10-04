<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class CreditRecovery extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'party_client_uuid', 'occurred_on', 'amount', 'method', 'note',
    ];

    protected function casts(): array
    {
        return [
            'occurred_on' => 'date',
            'amount' => 'decimal:2',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'party_client_uuid' => $this->party_client_uuid,
            'occurred_on' => optional($this->occurred_on)->toDateString(),
            'amount' => $this->amount,
            'method' => $this->method,
            'note' => $this->note,
        ] + $this->timestampPayload();
    }
}
