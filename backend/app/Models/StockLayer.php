<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class StockLayer extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'branch_id', 'product_id', 'qty_remaining', 'unit_cost',
        'source_event_id', 'received_at',
    ];

    protected function casts(): array
    {
        return [
            'qty_remaining' => 'decimal:3',
            'unit_cost' => 'decimal:4',
            'received_at' => 'datetime',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'company_id' => $this->company_id,
            'branch_id' => $this->branch_id,
            'product_id' => $this->product_id,
            'qty_remaining' => $this->qty_remaining,
            'unit_cost' => $this->unit_cost,
            'source_event_id' => $this->source_event_id,
            'received_at' => optional($this->received_at)->toJSON(),
        ] + $this->timestampPayload();
    }
}
