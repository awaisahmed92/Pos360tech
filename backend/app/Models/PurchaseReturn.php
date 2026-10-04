<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PurchaseReturn extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'branch_id', 'client_uuid', 'supplier_name', 'refund_method', 'source_client_uuid', 'note', 'occurred_at', 'total', 'created_by',
    ];

    protected function casts(): array
    {
        return [
            'occurred_at' => 'datetime',
            'total' => 'decimal:2',
        ];
    }

    public function lines(): HasMany
    {
        return $this->hasMany(PurchaseReturnLine::class);
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(Branch::class);
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'branch_id' => $this->branch_id,
            'branch_client_uuid' => $this->relationLoaded('branch') ? $this->branch?->client_uuid : null,
            'supplier_name' => $this->supplier_name,
            'refund_method' => $this->refund_method,
            'source_client_uuid' => $this->source_client_uuid,
            'note' => $this->note,
            'occurred_at' => optional($this->occurred_at)->toJSON(),
            'occurred_on' => optional($this->occurred_at)->toDateString(),
            'total' => $this->total,
            'lines' => $this->relationLoaded('lines') ? $this->lines->map->toSyncArray()->values() : [],
        ] + $this->timestampPayload();
    }
}
