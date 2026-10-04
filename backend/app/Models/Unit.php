<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class Unit extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'name_en', 'name_ur', 'short_name',
    ];

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'company_id' => $this->company_id,
            'name_en' => $this->name_en,
            'name_ur' => $this->name_ur,
            'short_name' => $this->short_name,
        ] + $this->timestampPayload();
    }
}
