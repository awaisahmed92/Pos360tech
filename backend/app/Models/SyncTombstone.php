<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class SyncTombstone extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'entity', 'record_id', 'client_uuid',
    ];

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'entity' => $this->entity,
            'record_id' => $this->record_id,
            'client_uuid' => $this->client_uuid,
        ] + $this->timestampPayload();
    }
}
