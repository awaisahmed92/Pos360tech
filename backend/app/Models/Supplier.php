<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class Supplier extends Model
{
    use PresentsTimestamps;

    protected $fillable = ['company_id', 'client_uuid', 'name', 'phone', 'address'];

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'name' => $this->name,
            'phone' => $this->phone,
            'address' => $this->address,
        ] + $this->timestampPayload();
    }
}
