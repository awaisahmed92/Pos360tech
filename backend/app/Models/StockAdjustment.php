<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class StockAdjustment extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'branch_id', 'location_id', 'kind',
        'reason', 'occurred_at', 'created_by',
    ];

    protected function casts(): array
    {
        return ['occurred_at' => 'datetime'];
    }

    public function lines(): HasMany
    {
        return $this->hasMany(StockAdjustmentLine::class);
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
            'company_id' => $this->company_id,
            'branch_id' => $this->branch_id,
            'location_id' => $this->location_id,
            'kind' => $this->kind,
            'reason' => $this->reason,
            'occurred_at' => optional($this->occurred_at)->toJSON(),
            'created_by' => $this->created_by,
            'lines' => $this->relationLoaded('lines')
                ? $this->lines->map->toSyncArray()->values()
                : [],
        ] + $this->timestampPayload();
    }
}
