<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LocationMoveLine extends Model
{
    protected $fillable = [
        'location_move_id', 'product_id', 'qty',
    ];

    protected function casts(): array
    {
        return ['qty' => 'decimal:3'];
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'product_client_uuid' => $this->relationLoaded('product') ? $this->product?->client_uuid : null,
            'qty' => $this->qty,
        ];
    }
}
