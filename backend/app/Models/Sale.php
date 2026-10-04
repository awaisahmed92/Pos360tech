<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Sale extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'branch_id', 'client_uuid', 'party_name', 'invoice_no',
        'occurred_at', 'payment_method', 'paid', 'total', 'note', 'created_by',
    ];

    protected function casts(): array
    {
        return [
            'occurred_at' => 'datetime',
            'paid' => 'decimal:2',
            'total' => 'decimal:2',
        ];
    }

    public function lines(): HasMany
    {
        return $this->hasMany(SaleLine::class);
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
            'party_name' => $this->party_name,
            'invoice_no' => $this->invoice_no,
            'occurred_at' => optional($this->occurred_at)->toJSON(),
            'occurred_on' => optional($this->occurred_at)->toDateString(),
            'payment_method' => $this->payment_method,
            'paid' => $this->paid,
            'total' => $this->total,
            'note' => $this->note,
            'item_count' => $this->relationLoaded('lines') ? $this->lines->count() : 0,
            'lines' => $this->relationLoaded('lines') ? $this->lines->map->toSyncArray()->values() : [],
        ] + $this->timestampPayload();
    }
}
