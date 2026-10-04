<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;

class BranchStock extends Model
{
    use PresentsTimestamps;

    protected $table = 'branch_stock';

    protected $fillable = [
        'company_id', 'branch_id', 'product_id', 'qty_on_hand', 'stock_value',
    ];

    protected function casts(): array
    {
        return [
            'qty_on_hand' => 'decimal:3',
            'stock_value' => 'decimal:2',
        ];
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'company_id' => $this->company_id,
            'branch_id' => $this->branch_id,
            'product_id' => $this->product_id,
            'qty_on_hand' => $this->qty_on_hand,
            'stock_value' => $this->stock_value,
        ] + $this->timestampPayload();
    }
}
