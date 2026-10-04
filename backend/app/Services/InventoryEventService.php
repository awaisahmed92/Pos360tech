<?php

namespace App\Services;

use App\Models\BranchStock;
use App\Models\InventoryEvent;
use App\Models\Location;
use App\Models\LocationStock;
use App\Models\Product;
use App\Models\StockLayer;
use App\Support\Dec;
use App\Support\InventoryEventType;
use Brick\Math\BigDecimal;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class InventoryEventService
{
    /**
     * Receive stock and create FIFO layers. One ledger event records the blended cost.
     * Slices keep their own unit cost so a later issue still consumes oldest cost first.
     *
     * @param  array<string, mixed>  $spec
     * @param  array<int, array{qty: string, unit_cost: string}>  $slices
     */
    public function receive(array $spec, array $slices): InventoryEvent
    {
        $qty = BigDecimal::zero();
        $value = BigDecimal::zero();
        $normalized = [];

        foreach ($slices as $slice) {
            $sliceQty = Dec::of($slice['qty']);
            $sliceCost = Dec::of($slice['unit_cost']);
            if ($sliceQty->isLessThanOrEqualTo(0)) {
                throw ValidationException::withMessages(['qty' => 'Quantity must be greater than zero.']);
            }
            if ($sliceCost->isNegative()) {
                throw ValidationException::withMessages(['unit_cost' => 'Unit cost cannot be negative.']);
            }
            $qty = $qty->plus($sliceQty);
            $value = $value->plus($sliceQty->multipliedBy($sliceCost));
            $normalized[] = ['qty' => Dec::qty($sliceQty), 'unit_cost' => Dec::cost($sliceCost)];
        }

        $location = $this->location($spec);
        $stock = $this->lockBranchStock($spec['company_id'], $spec['branch_id'], $spec['product_id']);
        $occurredAt = $this->occurredAt($spec);
        $remaining = $qty;

        $negativeLayers = StockLayer::query()
            ->where('branch_id', $spec['branch_id'])
            ->where('product_id', $spec['product_id'])
            ->where('qty_remaining', '<', 0)
            ->orderBy('received_at')
            ->orderBy('id')
            ->lockForUpdate()
            ->get();

        foreach ($negativeLayers as $layer) {
            if ($remaining->isZero()) {
                break;
            }
            $hole = Dec::of($layer->qty_remaining)->abs();
            $fill = $hole->isLessThan($remaining) ? $hole : $remaining;
            $next = Dec::of($layer->qty_remaining)->plus($fill);
            if ($next->isZero()) {
                $layer->delete();
            } else {
                $layer->qty_remaining = Dec::qty($next);
                $layer->save();
            }
            $remaining = $remaining->minus($fill);
        }

        $newQty = Dec::of($stock->qty_on_hand)->plus($qty);
        $unitCost = $qty->isZero()
            ? '0.0000'
            : Dec::cost($value->dividedBy($qty, 4, \Brick\Math\RoundingMode::HALF_UP));

        $event = $this->storeEvent($spec, $location->id, Dec::qty($qty), $unitCost, Dec::money($value), Dec::qty($newQty), $occurredAt);

        // The oldest inbound slices fill an existing negative hole. Only the
        // quantity still left after that hole becomes a new FIFO layer.
        $skip = $qty->minus($remaining);
        foreach ($normalized as $slice) {
            $sliceQty = Dec::of($slice['qty']);
            if ($skip->isPositive()) {
                if ($sliceQty->isLessThanOrEqualTo($skip)) {
                    $skip = $skip->minus($sliceQty);
                    continue;
                }
                $sliceQty = $sliceQty->minus($skip);
                $skip = BigDecimal::zero();
            }
            if ($sliceQty->isPositive()) {
                StockLayer::create([
                    'company_id' => $spec['company_id'],
                    'branch_id' => $spec['branch_id'],
                    'product_id' => $spec['product_id'],
                    'qty_remaining' => Dec::qty($sliceQty),
                    'unit_cost' => $slice['unit_cost'],
                    'source_event_id' => $event->id,
                    'received_at' => $occurredAt,
                ]);
            }
        }

        $this->adjustLocation($spec['company_id'], $location->id, $spec['product_id'], Dec::qty($qty));
        $stock->qty_on_hand = Dec::qty($newQty);
        $this->refreshValue($stock);

        return $event;
    }

    /**
     * Issue stock FIFO. Shortfalls are accepted and recorded as a negative layer
     * at the product purchase price so an offline sale is never dropped.
     *
     * @param  array<string, mixed>  $spec
     * @return array{event: InventoryEvent, slices: array<int, array{qty: string, unit_cost: string}>}
     */
    public function issue(array $spec): array
    {
        $qty = Dec::of($spec['qty'] ?? '0');
        if ($qty->isLessThanOrEqualTo(0)) {
            throw ValidationException::withMessages(['qty' => 'Quantity must be greater than zero.']);
        }

        $product = Product::query()->where('company_id', $spec['company_id'])->findOrFail($spec['product_id']);
        $location = $this->location($spec);
        $stock = $this->lockBranchStock($spec['company_id'], $spec['branch_id'], $spec['product_id']);
        $occurredAt = $this->occurredAt($spec);
        $need = $qty;
        $value = BigDecimal::zero();
        $slices = [];

        $layers = StockLayer::query()
            ->where('branch_id', $spec['branch_id'])
            ->where('product_id', $spec['product_id'])
            ->where('qty_remaining', '>', 0)
            ->orderBy('received_at')
            ->orderBy('id')
            ->lockForUpdate()
            ->get();

        foreach ($layers as $layer) {
            if ($need->isZero()) {
                break;
            }
            $take = Dec::of($layer->qty_remaining)->isLessThan($need) ? Dec::of($layer->qty_remaining) : $need;
            $layer->qty_remaining = Dec::qty(Dec::of($layer->qty_remaining)->minus($take));
            if (Dec::of($layer->qty_remaining)->isZero()) {
                $layer->delete();
            } else {
                $layer->save();
            }
            $value = $value->plus($take->multipliedBy(Dec::of($layer->unit_cost)));
            $slices[] = ['qty' => Dec::qty($take), 'unit_cost' => Dec::cost($layer->unit_cost)];
            $need = $need->minus($take);
        }

        $shortLayer = null;
        if ($need->isPositive()) {
            $fallback = Dec::cost($product->purchase_price);
            $value = $value->plus($need->multipliedBy(Dec::of($fallback)));
            $slices[] = ['qty' => Dec::qty($need), 'unit_cost' => $fallback];
            $shortLayer = StockLayer::create([
                'company_id' => $spec['company_id'],
                'branch_id' => $spec['branch_id'],
                'product_id' => $spec['product_id'],
                'qty_remaining' => Dec::qty($need->negated()),
                'unit_cost' => $fallback,
                'source_event_id' => null,
                'received_at' => $occurredAt,
            ]);
        }

        $newQty = Dec::of($stock->qty_on_hand)->minus($qty);
        $unitCost = Dec::cost($value->dividedBy($qty, 4, \Brick\Math\RoundingMode::HALF_UP));
        $event = $this->storeEvent(
            $spec,
            $location->id,
            Dec::qty($qty->negated()),
            $unitCost,
            Dec::money($value->negated()),
            Dec::qty($newQty),
            $occurredAt,
        );

        if ($shortLayer) {
            $shortLayer->source_event_id = $event->id;
            $shortLayer->save();
        }

        $this->adjustLocation($spec['company_id'], $location->id, $spec['product_id'], Dec::qty($qty->negated()));
        $stock->qty_on_hand = Dec::qty($newQty);
        $this->refreshValue($stock);

        return ['event' => $event, 'slices' => $slices];
    }

    /**
     * Move quantity between godowns. Branch on-hand and FIFO layers stay unchanged.
     *
     * @param  array<string, mixed>  $spec
     */
    public function move(array $spec): InventoryEvent
    {
        $qty = Dec::of($spec['qty'] ?? '0');
        if ($qty->isLessThanOrEqualTo(0)) {
            throw ValidationException::withMessages(['qty' => 'Quantity must be greater than zero.']);
        }

        $from = Location::query()
            ->where('company_id', $spec['company_id'])
            ->where('branch_id', $spec['branch_id'])
            ->find($spec['from_location_id']);
        $to = Location::query()
            ->where('company_id', $spec['company_id'])
            ->where('branch_id', $spec['branch_id'])
            ->find($spec['to_location_id']);

        if (! $from || ! $to) {
            throw ValidationException::withMessages(['location_id' => 'Both godowns must belong to this branch.']);
        }
        if ($from->id === $to->id) {
            throw ValidationException::withMessages(['location_id' => 'Choose two different godowns.']);
        }

        $stock = $this->lockBranchStock($spec['company_id'], $spec['branch_id'], $spec['product_id']);
        $occurredAt = $this->occurredAt($spec);
        $event = InventoryEvent::create([
            'company_id' => $spec['company_id'],
            'client_uuid' => $spec['client_uuid'] ?? (string) Str::uuid(),
            'branch_id' => $spec['branch_id'],
            'product_id' => $spec['product_id'],
            'location_id' => $from->id,
            'from_location_id' => $from->id,
            'to_location_id' => $to->id,
            'event_type' => InventoryEventType::LOCATION_MOVE,
            'qty' => Dec::qty($qty),
            'unit_cost' => '0.0000',
            'value' => '0.00',
            'running_balance' => Dec::qty($stock->qty_on_hand),
            'source_type' => $spec['source_type'] ?? null,
            'source_id' => $spec['source_id'] ?? null,
            'source_uuid' => $spec['source_uuid'] ?? null,
            'reason' => $spec['reason'] ?? null,
            'operator_id' => $spec['operator_id'] ?? null,
            'occurred_at' => $occurredAt,
        ]);

        $this->adjustLocation($spec['company_id'], $from->id, $spec['product_id'], Dec::qty($qty->negated()));
        $this->adjustLocation($spec['company_id'], $to->id, $spec['product_id'], Dec::qty($qty));

        return $event;
    }

    public function snapshot(int $companyId, array $pairs): array
    {
        $branchIds = collect($pairs)->pluck(0)->unique()->values();
        $productIds = collect($pairs)->pluck(1)->unique()->values();

        $balances = BranchStock::query()
            ->where('company_id', $companyId)
            ->whereIn('branch_id', $branchIds)
            ->whereIn('product_id', $productIds)
            ->get()
            ->map->toSyncArray()
            ->values();

        $layers = StockLayer::query()
            ->where('company_id', $companyId)
            ->whereIn('branch_id', $branchIds)
            ->whereIn('product_id', $productIds)
            ->orderBy('id')
            ->get()
            ->map->toSyncArray()
            ->values();

        $locationIds = Location::query()
            ->where('company_id', $companyId)
            ->whereIn('branch_id', $branchIds)
            ->pluck('id');

        $locationStocks = LocationStock::query()
            ->where('company_id', $companyId)
            ->whereIn('location_id', $locationIds)
            ->whereIn('product_id', $productIds)
            ->get()
            ->map->toSyncArray()
            ->values();

        return [
            'balances' => $balances,
            'layers' => $layers,
            'location_stocks' => $locationStocks,
        ];
    }

    private function storeEvent(array $spec, int $locationId, string $qty, string $unitCost, string $value, string $runningBalance, Carbon $occurredAt): InventoryEvent
    {
        return InventoryEvent::create([
            'company_id' => $spec['company_id'],
            'client_uuid' => $spec['client_uuid'] ?? (string) Str::uuid(),
            'branch_id' => $spec['branch_id'],
            'product_id' => $spec['product_id'],
            'location_id' => $locationId,
            'event_type' => $spec['event_type'],
            'qty' => $qty,
            'unit_cost' => $unitCost,
            'value' => $value,
            'running_balance' => $runningBalance,
            'source_type' => $spec['source_type'] ?? null,
            'source_id' => $spec['source_id'] ?? null,
            'source_uuid' => $spec['source_uuid'] ?? null,
            'reason' => $spec['reason'] ?? null,
            'operator_id' => $spec['operator_id'] ?? null,
            'occurred_at' => $occurredAt,
        ]);
    }

    private function location(array $spec): Location
    {
        if (! empty($spec['location_id'])) {
            $location = Location::query()
                ->where('company_id', $spec['company_id'])
                ->where('branch_id', $spec['branch_id'])
                ->find($spec['location_id']);
            if (! $location) {
                throw ValidationException::withMessages(['location_id' => 'Godown was not found for this branch.']);
            }

            return $location;
        }

        $location = Location::query()
            ->where('company_id', $spec['company_id'])
            ->where('branch_id', $spec['branch_id'])
            ->where('is_default', true)
            ->first();

        if (! $location) {
            throw ValidationException::withMessages(['location_id' => 'This branch has no default godown.']);
        }

        return $location;
    }

    private function lockBranchStock(int $companyId, int $branchId, int $productId): BranchStock
    {
        $stock = BranchStock::query()
            ->where('branch_id', $branchId)
            ->where('product_id', $productId)
            ->lockForUpdate()
            ->first();

        if ($stock) {
            return $stock;
        }

        BranchStock::query()->create([
            'company_id' => $companyId,
            'branch_id' => $branchId,
            'product_id' => $productId,
            'qty_on_hand' => '0.000',
            'stock_value' => '0.00',
        ]);

        return BranchStock::query()
            ->where('branch_id', $branchId)
            ->where('product_id', $productId)
            ->lockForUpdate()
            ->firstOrFail();
    }

    private function adjustLocation(int $companyId, int $locationId, int $productId, string $signedQty): void
    {
        $row = LocationStock::query()
            ->where('location_id', $locationId)
            ->where('product_id', $productId)
            ->lockForUpdate()
            ->first();

        if (! $row) {
            $row = LocationStock::query()->create([
                'company_id' => $companyId,
                'location_id' => $locationId,
                'product_id' => $productId,
                'qty_on_hand' => '0.000',
            ]);
            $row = LocationStock::query()->whereKey($row->id)->lockForUpdate()->firstOrFail();
        }

        $row->qty_on_hand = Dec::qty(Dec::of($row->qty_on_hand)->plus(Dec::of($signedQty)));
        $row->save();
    }

    private function refreshValue(BranchStock $stock): void
    {
        $value = BigDecimal::zero();
        $layers = StockLayer::query()
            ->where('branch_id', $stock->branch_id)
            ->where('product_id', $stock->product_id)
            ->get();

        foreach ($layers as $layer) {
            $value = $value->plus(Dec::of($layer->qty_remaining)->multipliedBy(Dec::of($layer->unit_cost)));
        }

        $stock->stock_value = Dec::money($value);
        $stock->save();
    }

    private function occurredAt(array $spec): Carbon
    {
        // Eloquent writes the wall-clock value without converting zones, so normalise first.
        return empty($spec['occurred_at']) ? now() : Carbon::parse($spec['occurred_at'])->setTimezone(config('app.timezone'));
    }
}
