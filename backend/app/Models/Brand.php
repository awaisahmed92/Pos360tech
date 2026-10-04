<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class Brand extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'name_en', 'name_ur', 'code', 'is_active',
    ];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'company_id' => $this->company_id,
            'name_en' => $this->name_en,
            'name_ur' => $this->name_ur,
            'code' => $this->code,
            'is_active' => $this->is_active,
        ] + $this->timestampPayload();
    }
}
