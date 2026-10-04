<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class PurchasePayment extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'purchase_client_uuid', 'amount', 'method', 'occurred_on', 'note',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'occurred_on' => 'date',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'purchase_client_uuid' => $this->purchase_client_uuid,
            'amount' => $this->amount,
            'method' => $this->method,
            'occurred_on' => optional($this->occurred_on)->toDateString(),
            'note' => $this->note,
        ] + $this->timestampPayload();
    }
}
