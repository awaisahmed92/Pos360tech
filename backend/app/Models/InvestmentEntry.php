<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InvestmentEntry extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'partner_id', 'client_uuid', 'kind', 'method', 'amount', 'occurred_on', 'note',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'occurred_on' => 'date',
        ];
    }

    public function partner(): BelongsTo
    {
        return $this->belongsTo(InvestmentPartner::class, 'partner_id');
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'partner_id' => $this->partner_id,
            'partner_client_uuid' => $this->relationLoaded('partner') ? $this->partner?->client_uuid : null,
            'partner_name' => $this->relationLoaded('partner') ? $this->partner?->name : null,
            'kind' => $this->kind,
            'method' => $this->method,
            'amount' => $this->amount,
            'occurred_on' => optional($this->occurred_on)->toDateString(),
            'note' => $this->note,
        ] + $this->timestampPayload();
    }
}
