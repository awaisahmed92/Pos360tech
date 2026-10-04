<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class Expense extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'occurred_on', 'invoice_no', 'account_client_uuid',
        'account_name', 'narration', 'amount', 'method',
    ];

    protected function casts(): array
    {
        return [
            'occurred_on' => 'date',
            'amount' => 'decimal:2',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'occurred_on' => optional($this->occurred_on)->toDateString(),
            'invoice_no' => $this->invoice_no,
            'account_client_uuid' => $this->account_client_uuid,
            'account_name' => $this->account_name,
            'narration' => $this->narration,
            'amount' => $this->amount,
            'method' => $this->method,
        ] + $this->timestampPayload();
    }
}
