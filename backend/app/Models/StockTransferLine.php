<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StockTransferLine extends Model
{
    protected $fillable = [
        'stock_transfer_id', 'product_id', 'qty', 'unit_cost', 'value',
    ];

    protected function casts(): array
    {
        return [
            'qty' => 'decimal:3',
            'unit_cost' => 'decimal:4',
            'value' => 'decimal:2',
        ];
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
            'unit_cost' => $this->unit_cost,
            'value' => $this->value,
        ];
    }
}
