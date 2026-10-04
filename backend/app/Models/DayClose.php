<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class DayClose extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'closed_on', 'opening_cash', 'counted_cash', 'note',
    ];

    protected function casts(): array
    {
        return [
            'closed_on' => 'date',
            'opening_cash' => 'decimal:2',
            'counted_cash' => 'decimal:2',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'closed_on' => optional($this->closed_on)->toDateString(),
            'opening_cash' => $this->opening_cash,
            'counted_cash' => $this->counted_cash,
            'note' => $this->note,
        ] + $this->timestampPayload();
    }
}
