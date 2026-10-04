<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InventoryEvent extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'branch_id', 'product_id', 'location_id',
        'from_location_id', 'to_location_id', 'event_type', 'qty', 'unit_cost',
        'value', 'running_balance', 'source_type', 'source_id', 'source_uuid',
        'reason', 'operator_id', 'occurred_at',
    ];

    protected function casts(): array
    {
        return [
            'qty' => 'decimal:3',
            'unit_cost' => 'decimal:4',
            'value' => 'decimal:2',
            'running_balance' => 'decimal:3',
            'occurred_at' => 'datetime',
        ];
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(Branch::class);
    }

    public function operator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'operator_id');
    }

    public function location(): BelongsTo
    {
        return $this->belongsTo(Location::class);
    }

    public function fromLocation(): BelongsTo
    {
        return $this->belongsTo(Location::class, 'from_location_id');
    }

    public function toLocation(): BelongsTo
    {
        return $this->belongsTo(Location::class, 'to_location_id');
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'company_id' => $this->company_id,
            'branch_id' => $this->branch_id,
            'branch_name' => $this->relationLoaded('branch') ? $this->branch?->name : null,
            'product_id' => $this->product_id,
            'product_client_uuid' => $this->relationLoaded('product') ? $this->product?->client_uuid : null,
            'product_name' => $this->relationLoaded('product') ? $this->product?->name_en : null,
            'product_code' => $this->relationLoaded('product') ? $this->product?->code : null,
            'location_id' => $this->location_id,
            'location_name' => $this->relationLoaded('location') ? $this->location?->name : null,
            'from_location_id' => $this->from_location_id,
            'from_location_name' => $this->relationLoaded('fromLocation') ? $this->fromLocation?->name : null,
            'to_location_id' => $this->to_location_id,
            'to_location_name' => $this->relationLoaded('toLocation') ? $this->toLocation?->name : null,
            'event_type' => $this->event_type,
            'qty' => $this->qty,
            'unit_cost' => $this->unit_cost,
            'value' => $this->value,
            'running_balance' => $this->running_balance,
            'source_type' => $this->source_type,
            'source_id' => $this->source_id,
            'source_uuid' => $this->source_uuid,
            'reason' => $this->reason,
            'operator_id' => $this->operator_id,
            'operator_name' => $this->relationLoaded('operator') ? $this->operator?->name : null,
            'occurred_at' => optional($this->occurred_at)->toJSON(),
            'sync_status' => 'synced',
        ] + $this->timestampPayload();
    }
}
