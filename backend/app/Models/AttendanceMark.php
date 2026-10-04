<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class AttendanceMark extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'employee_client_uuid', 'work_date',
        'status', 'check_in', 'check_out', 'note',
    ];

    protected function casts(): array
    {
        return ['work_date' => 'date'];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'employee_client_uuid' => $this->employee_client_uuid,
            'work_date' => optional($this->work_date)->toDateString(),
            'status' => $this->status,
            'check_in' => $this->check_in,
            'check_out' => $this->check_out,
            'note' => $this->note,
        ] + $this->timestampPayload();
    }
}
