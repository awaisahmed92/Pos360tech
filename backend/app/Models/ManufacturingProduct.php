<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class ManufacturingProduct extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'code', 'barcode', 'name', 'unit_client_uuid', 'qty',
        'sale_price', 'wholesale_price', 'description', 'packaging', 'materials',
    ];

    protected function casts(): array
    {
        return [
            'qty' => 'decimal:3',
            'sale_price' => 'decimal:2',
            'wholesale_price' => 'decimal:2',
            'packaging' => 'array',
            'materials' => 'array',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'code' => $this->code,
            'barcode' => $this->barcode,
            'name' => $this->name,
            'unit_client_uuid' => $this->unit_client_uuid,
            'qty' => $this->qty,
            'sale_price' => $this->sale_price,
            'wholesale_price' => $this->wholesale_price,
            'description' => $this->description,
            'packaging' => $this->packaging ?? [],
            'materials' => $this->materials ?? [],
        ] + $this->timestampPayload();
    }
}
