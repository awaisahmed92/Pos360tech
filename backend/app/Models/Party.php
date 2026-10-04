<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class Party extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'type', 'name', 'name_ur', 'phone', 'route_day',
        'area_client_uuid', 'email', 'cnic', 'ntn', 'strn', 'opening_balance',
        'balance_side', 'price_mode', 'address',
    ];

    protected function casts(): array
    {
        return ['opening_balance' => 'decimal:2'];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'type' => $this->type,
            'name' => $this->name,
            'name_ur' => $this->name_ur,
            'phone' => $this->phone,
            'route_day' => $this->route_day,
            'area_client_uuid' => $this->area_client_uuid,
            'email' => $this->email,
            'cnic' => $this->cnic,
            'ntn' => $this->ntn,
            'strn' => $this->strn,
            'opening_balance' => $this->opening_balance,
            'balance_side' => $this->balance_side,
            'price_mode' => $this->price_mode,
            'address' => $this->address,
        ] + $this->timestampPayload();
    }
}
