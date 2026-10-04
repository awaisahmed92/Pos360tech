<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PurchaseLine extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'purchase_id', 'product_id', 'qty', 'unit_cost', 'tax_percent', 'line_total',
        'new_sale_price', 'new_wholesale', 'batch_no', 'expiry',
    ];

    protected function casts(): array
    {
        return [
            'qty' => 'decimal:3',
            'unit_cost' => 'decimal:4',
            'tax_percent' => 'decimal:2',
            'line_total' => 'decimal:2',
            'new_sale_price' => 'decimal:2',
            'new_wholesale' => 'decimal:2',
            'expiry' => 'date',
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
            'qty' => $this->qty,
            'unit_cost' => $this->unit_cost,
            'tax_percent' => $this->tax_percent,
            'line_total' => $this->line_total,
            'new_sale_price' => $this->new_sale_price,
            'new_wholesale' => $this->new_wholesale,
            'batch_no' => $this->batch_no,
            'expiry' => optional($this->expiry)->toDateString(),
        ];
    }
}
