<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class Employee extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'name', 'name_ur', 'phone', 'cnic', 'designation',
        'employment_type', 'monthly_salary', 'joined_on', 'commission_rate', 'commission_on',
        'status', 'notes', 'allow_login', 'email',
    ];

    protected function casts(): array
    {
        return [
            'monthly_salary' => 'decimal:2',
            'commission_rate' => 'decimal:2',
            'joined_on' => 'date',
            'allow_login' => 'boolean',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'name' => $this->name,
            'name_ur' => $this->name_ur,
            'phone' => $this->phone,
            'cnic' => $this->cnic,
            'designation' => $this->designation,
            'employment_type' => $this->employment_type,
            'monthly_salary' => $this->monthly_salary,
            'joined_on' => optional($this->joined_on)->toDateString(),
            'commission_rate' => $this->commission_rate,
            'commission_on' => $this->commission_on,
            'status' => $this->status,
            'notes' => $this->notes,
            'allow_login' => $this->allow_login,
            'email' => $this->email,
        ] + $this->timestampPayload();
    }
}
