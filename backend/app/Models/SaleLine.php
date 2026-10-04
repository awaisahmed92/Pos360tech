<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SaleLine extends Model
{
    public $timestamps = false;

    protected $fillable = ['sale_id', 'product_id', 'line_name', 'is_return', 'discount', 'qty', 'unit_price', 'unit_cost', 'line_total'];

    protected function casts(): array
    {
        return [
            'is_return' => 'boolean',
            'discount' => 'decimal:2',
            'qty' => 'decimal:3',
            'unit_price' => 'decimal:2',
            'unit_cost' => 'decimal:4',
            'line_total' => 'decimal:2',
        ];
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function toSyncArray(): array
    {
        return [
            'product_id' => $this->product_id,
            'product_client_uuid' => $this->relationLoaded('product') ? $this->product?->client_uuid : null,
            'name' => $this->line_name,
            'is_return' => (bool) $this->is_return,
            'discount' => $this->discount,
            'qty' => $this->qty,
            'unit_price' => $this->unit_price,
            'unit_cost' => $this->unit_cost,
            'line_total' => $this->line_total,
        ];
    }
}
