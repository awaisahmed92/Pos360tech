<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Purchase extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'branch_id', 'client_uuid', 'supplier_id', 'supplier_name', 'invoice_no',
        'occurred_at', 'payment_method', 'paid', 'subtotal', 'tax', 'total', 'note', 'update_cost', 'created_by',
    ];

    protected function casts(): array
    {
        return [
            'occurred_at' => 'datetime',
            'paid' => 'decimal:2',
            'subtotal' => 'decimal:2',
            'tax' => 'decimal:2',
            'total' => 'decimal:2',
            'update_cost' => 'boolean',
        ];
    }

    public function lines(): HasMany
    {
        return $this->hasMany(PurchaseLine::class);
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
            'invoice_no' => $this->invoice_no,
            'occurred_at' => optional($this->occurred_at)->toJSON(),
            'occurred_on' => optional($this->occurred_at)->toDateString(),
            'payment_method' => $this->payment_method,
            'paid' => $this->paid,
            'subtotal' => $this->subtotal,
            'tax' => $this->tax,
            'total' => $this->total,
            'note' => $this->note,
            'update_cost' => $this->update_cost,
            'item_count' => $this->relationLoaded('lines') ? $this->lines->count() : 0,
            'lines' => $this->relationLoaded('lines') ? $this->lines->map->toSyncArray()->values() : [],
        ] + $this->timestampPayload();
    }
}
