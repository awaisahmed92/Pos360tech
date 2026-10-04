<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Cheque extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'branch_id', 'client_uuid', 'direction', 'cheque_no', 'bank',
        'party_name', 'amount', 'issued_on', 'cleared_on', 'status', 'note',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'issued_on' => 'date',
            'cleared_on' => 'date',
        ];
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
            'direction' => $this->direction,
            'cheque_no' => $this->cheque_no,
            'bank' => $this->bank,
            'party_name' => $this->party_name,
            'amount' => $this->amount,
            'issued_on' => optional($this->issued_on)->toDateString(),
            'cleared_on' => optional($this->cleared_on)->toDateString(),
            'status' => $this->status,
            'note' => $this->note,
        ] + $this->timestampPayload();
    }
}
