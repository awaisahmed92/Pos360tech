<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class Area extends Model
{
    use PresentsTimestamps;

    protected $fillable = ['company_id', 'client_uuid', 'name'];

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'name' => $this->name,
        ] + $this->timestampPayload();
    }
}
