<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class SalaryPayment extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'employee_client_uuid', 'period',
        'kind', 'amount', 'method', 'paid_on', 'note',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'paid_on' => 'date',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'employee_client_uuid' => $this->employee_client_uuid,
            'period' => $this->period,
            'kind' => $this->kind,
            'amount' => $this->amount,
            'method' => $this->method,
            'paid_on' => optional($this->paid_on)->toDateString(),
            'note' => $this->note,
        ] + $this->timestampPayload();
    }
}
