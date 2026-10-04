<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class LocationStock extends Model
{
    use PresentsTimestamps;

    protected $table = 'location_stock';

    protected $fillable = [
        'company_id', 'location_id', 'product_id', 'qty_on_hand',
    ];

    protected function casts(): array
    {
        return [
            'qty_on_hand' => 'decimal:3',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'company_id' => $this->company_id,
            'location_id' => $this->location_id,
            'product_id' => $this->product_id,
            'qty_on_hand' => $this->qty_on_hand,
        ] + $this->timestampPayload();
    }
}
