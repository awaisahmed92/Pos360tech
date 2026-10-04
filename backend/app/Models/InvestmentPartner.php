<?php

namespace App\Models;

use App\Models\Concerns\PresentsTimestamps;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class InvestmentPartner extends Model
{
    use PresentsTimestamps;

    protected $fillable = [
        'company_id', 'client_uuid', 'name', 'phone', 'cnic', 'joined_on', 'address',
        'profit_share', 'loss_share', 'shares_loss', 'is_owner', 'note',
    ];

    protected function casts(): array
    {
        return [
            'joined_on' => 'date',
            'profit_share' => 'decimal:2',
            'loss_share' => 'decimal:2',
            'shares_loss' => 'boolean',
            'is_owner' => 'boolean',
        ];
    }

    public function entries(): HasMany
    {
        return $this->hasMany(InvestmentEntry::class, 'partner_id');
    }

    public function toSyncArray(): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'name' => $this->name,
            'phone' => $this->phone,
            'cnic' => $this->cnic,
            'joined_on' => optional($this->joined_on)->toDateString(),
            'address' => $this->address,
            'profit_share' => $this->profit_share,
            'loss_share' => $this->loss_share,
            'shares_loss' => $this->shares_loss,
            'is_owner' => $this->is_owner,
            'note' => $this->note,
        ] + $this->timestampPayload();
    }
}
