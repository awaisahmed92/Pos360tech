<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class ShopDocument extends Model
{
    use PresentsTimestamps;

    protected $fillable = ['company_id', 'entity', 'client_uuid', 'payload'];

    protected function casts(): array
    {
        return ['payload' => 'array'];
    }

    public function toSyncArray(): array
    {
        $payload = is_array($this->payload) ? $this->payload : [];

        return array_merge($payload, [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'entity' => $this->entity,
        ], $this->timestampPayload());
    }
}
