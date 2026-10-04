<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PurchaseReturnLine extends Model
{
    public $timestamps = false;

    protected $fillable = ['purchase_return_id', 'product_id', 'qty', 'unit_cost', 'line_total'];

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function toSyncArray(): array
    {
        return [
            'product_id' => $this->product_id,
            'product_client_uuid' => $this->relationLoaded('product') ? $this->product?->client_uuid : null,
            'qty' => $this->qty,
            'unit_cost' => $this->unit_cost,
            'line_total' => $this->line_total,
        ];
    }
}
