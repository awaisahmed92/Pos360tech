<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class PurchaseOrder extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'supplier_name', 'occurred_on', 'note', 'status', 'lines',
    ];

    protected function casts(): array
    {
        return [
            'occurred_on' => 'date',
            'lines' => 'array',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'supplier_name' => $this->supplier_name,
            'occurred_on' => optional($this->occurred_on)->toDateString(),
            'note' => $this->note,
            'status' => $this->status,
            'lines' => $this->lines ?? [],
        ] + $this->timestampPayload();
    }
}
