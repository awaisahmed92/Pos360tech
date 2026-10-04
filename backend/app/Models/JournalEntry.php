<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class JournalEntry extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'branch_id', 'client_uuid', 'invoice_no', 'occurred_on', 'narration',
        'category', 'method', 'bank_name', 'debit', 'credit',
    ];

    protected function casts(): array
    {
        return [
            'occurred_on' => 'date',
            'debit' => 'decimal:2',
            'credit' => 'decimal:2',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'branch_id' => $this->branch_id,
            'invoice_no' => $this->invoice_no,
            'occurred_on' => optional($this->occurred_on)->toDateString(),
            'narration' => $this->narration,
            'category' => $this->category,
            'method' => $this->method,
            'bank_name' => $this->bank_name,
            'debit' => $this->debit,
            'credit' => $this->credit,
        ] + $this->timestampPayload();
    }
}
