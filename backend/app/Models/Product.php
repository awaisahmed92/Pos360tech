<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Product extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'code', 'barcode', 'name_en', 'name_ur',
        'category_id', 'brand_id', 'unit_id', 'purchase_price', 'sale_price',
        'wholesale_price', 'alert_qty', 'track_stock', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'purchase_price' => 'decimal:2',
            'sale_price' => 'decimal:2',
            'wholesale_price' => 'decimal:2',
            'alert_qty' => 'decimal:3',
            'track_stock' => 'boolean',
            'is_active' => 'boolean',
        ];
    }

    public function unit(): BelongsTo
    {
        return $this->belongsTo(Unit::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function brand(): BelongsTo
    {
        return $this->belongsTo(Brand::class);
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'company_id' => $this->company_id,
            'code' => $this->code,
            'barcode' => $this->barcode,
            'name_en' => $this->name_en,
            'name_ur' => $this->name_ur,
            'category_id' => $this->category_id,
            'category_client_uuid' => $this->relationLoaded('category') ? $this->category?->client_uuid : null,
            'brand_id' => $this->brand_id,
            'brand_client_uuid' => $this->relationLoaded('brand') ? $this->brand?->client_uuid : null,
            'unit_id' => $this->unit_id,
            'unit_client_uuid' => $this->relationLoaded('unit') ? $this->unit?->client_uuid : null,
            'unit_short_name' => $this->relationLoaded('unit') ? $this->unit?->short_name : null,
            'purchase_price' => $this->purchase_price,
            'sale_price' => $this->sale_price,
            'wholesale_price' => $this->wholesale_price,
            'alert_qty' => $this->alert_qty,
            'track_stock' => $this->track_stock,
            'is_active' => $this->is_active,
        ] + $this->timestampPayload();
    }
}
