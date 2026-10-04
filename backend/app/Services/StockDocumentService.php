<?php

namespace App\Services;

use App\Models\BranchStock;
use App\Models\InventoryEvent;
use App\Models\LocationMove;
use App\Models\LocationMoveLine;
use App\Models\Product;
use App\Models\Purchase;
use App\Models\PurchaseLine;
use App\Models\PurchaseReturn;
use App\Models\PurchaseReturnLine;
use App\Models\Sale;
use App\Models\SaleLine;
use App\Models\StockAdjustment;
use App\Models\StockAdjustmentLine;
use App\Models\StockTransfer;
use App\Models\StockTransferLine;
use App\Models\StockWriteOff;
use App\Models\StockWriteOffLine;
use App\Models\User;
use App\Support\Dec;
use App\Support\InventoryEventType;
use Brick\Math\BigDecimal;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class StockDocumentService
{
    public function __construct(
        private readonly CompanyLookup $lookup,
        private readonly InventoryEventService $inventory,
    ) {}

    public function apply(User $user, string $entity, string $action, array $payload): array
    {
        if ($action !== 'create') {
            throw ValidationException::withMessages(['action' => 'Posted stock documents cannot be edited.']);
        }

        return match ($entity) {
            'stock_adjustment' => $this->adjust($user, $payload),
            'stock_transfer' => $this->transfer($user, $payload),
            'stock_write_off' => $this->writeOff($user, $payload),
            'location_move' => $this->move($user, $payload),
            'purchase' => $this->purchase($user, $payload),
            'purchase_return' => $this->purchaseReturn($user, $payload),
            'sale' => $this->sale($user, $payload),
            default => throw ValidationException::withMessages(['entity' => 'Unknown stock document.']),
        };
    }

    public function adjust(User $user, array $payload): array
    {
        $this->assertUuid($payload);
        $existing = StockAdjustment::query()
            ->with('lines.product')
            ->where('company_id', $user->company_id)
            ->where('client_uuid', $payload['client_uuid'])
            ->first();
        if ($existing) {
            return $this->presentExisting($user, $existing, 'stock_adjustment');
        }

        $kind = $payload['kind'] ?? '';
        $eventType = match ($kind) {
            'opening' => InventoryEventType::OPENING,
            'increase' => InventoryEventType::ADJUSTMENT_IN,
            default => $kind === 'decrease' ? InventoryEventType::ADJUSTMENT_OUT : null,
        };
        if (! $eventType) {
            throw ValidationException::withMessages(['kind' => 'Kind must be opening, increase, or decrease.']);
        }

        $branch = $this->lookup->branch($user->company_id, $payload);
        $location = $this->optionalLocation($user, $payload, $branch->id);
        $lines = $this->lines($user, $payload, $kind !== 'decrease');

        return DB::transaction(function () use ($user, $payload, $branch, $location, $lines, $kind, $eventType) {
            $doc = StockAdjustment::create([
                'company_id' => $user->company_id,
                'client_uuid' => $payload['client_uuid'],
                'branch_id' => $branch->id,
                'location_id' => $location?->id,
                'kind' => $kind,
                'reason' => $this->nullableText($payload, 'reason'),
                'occurred_at' => $this->occurredAt($payload),
                'created_by' => $user->id,
            ]);

            $pairs = [];
            foreach ($lines as $line) {
                $spec = $this->spec($user, $branch->id, $location?->id, $line['product'], $eventType, $doc, $payload);
                if ($kind === 'decrease') {
                    $issued = $this->inventory->issue($spec + ['qty' => $line['qty']]);
                    $event = $issued['event'];
                } else {
                    $event = $this->inventory->receive($spec, [[
                        'qty' => $line['qty'],
                        'unit_cost' => $line['unit_cost'],
                    ]]);
                }
                StockAdjustmentLine::create([
                    'stock_adjustment_id' => $doc->id,
                    'product_id' => $line['product']->id,
                    'qty' => $line['qty'],
                    'unit_cost' => Dec::cost($event->unit_cost),
                    'value' => Dec::money(Dec::of($event->value)->abs()),
                ]);
                $pairs[] = [$branch->id, $line['product']->id];
            }

            return $this->present($user, $doc->load('lines.product'), 'stock_adjustment', $pairs, false);
        });
    }

    public function writeOff(User $user, array $payload): array
    {
        $this->assertUuid($payload);
        $existing = StockWriteOff::query()
            ->with('lines.product')
            ->where('company_id', $user->company_id)
            ->where('client_uuid', $payload['client_uuid'])
            ->first();
        if ($existing) {
            return $this->presentExisting($user, $existing, 'stock_write_off');
        }

        $branch = $this->lookup->branch($user->company_id, $payload);
        $location = $this->optionalLocation($user, $payload, $branch->id);
        $lines = $this->lines($user, $payload, false);

        return DB::transaction(function () use ($user, $payload, $branch, $location, $lines) {
            $doc = StockWriteOff::create([
                'company_id' => $user->company_id,
                'client_uuid' => $payload['client_uuid'],
                'branch_id' => $branch->id,
                'location_id' => $location?->id,
                'reason' => $this->nullableText($payload, 'reason'),
                'occurred_at' => $this->occurredAt($payload),
                'created_by' => $user->id,
            ]);
            $pairs = [];
            foreach ($lines as $line) {
                $issued = $this->inventory->issue($this->spec(
                    $user,
                    $branch->id,
                    $location?->id,
                    $line['product'],
                    InventoryEventType::WRITE_OFF,
                    $doc,
                    $payload,
                ) + ['qty' => $line['qty']]);
                StockWriteOffLine::create([
                    'stock_write_off_id' => $doc->id,
                    'product_id' => $line['product']->id,
                    'qty' => $line['qty'],
                    'unit_cost' => Dec::cost($issued['event']->unit_cost),
                    'value' => Dec::money(Dec::of($issued['event']->value)->abs()),
                ]);
                $pairs[] = [$branch->id, $line['product']->id];
            }

            return $this->present($user, $doc->load('lines.product'), 'stock_write_off', $pairs, false);
        });
    }

    public function transfer(User $user, array $payload): array
    {
        $this->assertUuid($payload);
        $existing = StockTransfer::query()
            ->with('lines.product')
            ->where('company_id', $user->company_id)
            ->where('client_uuid', $payload['client_uuid'])
            ->first();
        if ($existing) {
            return $this->presentExisting($user, $existing, 'stock_transfer');
        }

        $from = $this->lookup->branch($user->company_id, $payload, 'from_branch_id', 'from_branch_client_uuid');
        $to = $this->lookup->branch($user->company_id, $payload, 'to_branch_id', 'to_branch_client_uuid');
        if ($from->id === $to->id) {
            throw ValidationException::withMessages(['to_branch_id' => 'Choose a different destination branch.']);
        }
        $fromLocation = $this->optionalLocation($user, [
            'location_id' => $payload['from_location_id'] ?? null,
            'location_client_uuid' => $payload['from_location_client_uuid'] ?? null,
        ], $from->id);
        $toLocation = $this->optionalLocation($user, [
            'location_id' => $payload['to_location_id'] ?? null,
            'location_client_uuid' => $payload['to_location_client_uuid'] ?? null,
        ], $to->id);
        $lines = $this->lines($user, $payload, false);

        return DB::transaction(function () use ($user, $payload, $from, $to, $fromLocation, $toLocation, $lines) {
            $doc = StockTransfer::create([
                'company_id' => $user->company_id,
                'client_uuid' => $payload['client_uuid'],
                'from_branch_id' => $from->id,
                'to_branch_id' => $to->id,
                'from_location_id' => $fromLocation?->id,
                'to_location_id' => $toLocation?->id,
                'reason' => $this->nullableText($payload, 'reason'),
                'occurred_at' => $this->occurredAt($payload),
                'created_by' => $user->id,
            ]);
            $pairs = [];
            foreach ($lines as $line) {
                $issued = $this->inventory->issue($this->spec(
                    $user,
                    $from->id,
                    $fromLocation?->id,
                    $line['product'],
                    InventoryEventType::TRANSFER_OUT,
                    $doc,
                    $payload,
                ) + ['qty' => $line['qty']]);
                $this->inventory->receive($this->spec(
                    $user,
                    $to->id,
                    $toLocation?->id,
                    $line['product'],
                    InventoryEventType::TRANSFER_IN,
                    $doc,
                    $payload,
                ), $issued['slices']);
                $cost = Dec::money(Dec::of($issued['event']->value)->abs());
                StockTransferLine::create([
                    'stock_transfer_id' => $doc->id,
                    'product_id' => $line['product']->id,
                    'qty' => $line['qty'],
                    'unit_cost' => Dec::cost($issued['event']->unit_cost),
                    'value' => $cost,
                ]);
                $pairs[] = [$from->id, $line['product']->id];
                $pairs[] = [$to->id, $line['product']->id];
            }

            return $this->present($user, $doc->load('lines.product'), 'stock_transfer', $pairs, false);
        });
    }

    public function move(User $user, array $payload): array
    {
        $this->assertUuid($payload);
        $existing = LocationMove::query()
            ->with('lines.product')
            ->where('company_id', $user->company_id)
            ->where('client_uuid', $payload['client_uuid'])
            ->first();
        if ($existing) {
            return $this->presentExisting($user, $existing, 'location_move');
        }

        $branch = $this->lookup->branch($user->company_id, $payload);
        $from = $this->lookup->location($user->company_id, $payload, 'from_location_id', 'from_location_client_uuid');
        $to = $this->lookup->location($user->company_id, $payload, 'to_location_id', 'to_location_client_uuid');
        if ($from->branch_id !== $branch->id || $to->branch_id !== $branch->id) {
            throw ValidationException::withMessages(['location_id' => 'Both godowns must belong to the selected branch.']);
        }
        $lines = $this->lines($user, $payload, false);

        return DB::transaction(function () use ($user, $payload, $branch, $from, $to, $lines) {
            $doc = LocationMove::create([
                'company_id' => $user->company_id,
                'client_uuid' => $payload['client_uuid'],
                'branch_id' => $branch->id,
                'from_location_id' => $from->id,
                'to_location_id' => $to->id,
                'reason' => $this->nullableText($payload, 'reason'),
                'occurred_at' => $this->occurredAt($payload),
                'created_by' => $user->id,
            ]);
            $pairs = [];
            foreach ($lines as $line) {
                $this->inventory->move([
                    'company_id' => $user->company_id,
                    'branch_id' => $branch->id,
                    'product_id' => $line['product']->id,
                    'from_location_id' => $from->id,
                    'to_location_id' => $to->id,
                    'qty' => $line['qty'],
                    'source_type' => 'location_move',
                    'source_id' => $doc->id,
                    'source_uuid' => $doc->client_uuid,
                    'reason' => $doc->reason,
                    'operator_id' => $user->id,
                    'occurred_at' => $doc->occurred_at,
                ]);
                LocationMoveLine::create([
                    'location_move_id' => $doc->id,
                    'product_id' => $line['product']->id,
                    'qty' => $line['qty'],
                ]);
                $pairs[] = [$branch->id, $line['product']->id];
            }

            return $this->present($user, $doc->load('lines.product'), 'location_move', $pairs, false);
        });
    }

    public function purchase(User $user, array $payload): array
    {
        $this->assertUuid($payload);
        $existing = Purchase::query()
            ->with(['lines.product', 'branch'])
            ->where('company_id', $user->company_id)
            ->where('client_uuid', $payload['client_uuid'])
            ->first();
        if ($existing) {
            return $this->presentExisting($user, $existing, 'purchase');
        }

        $branch = $this->lookup->branch($user->company_id, $payload);
        $location = $this->optionalLocation($user, $payload, $branch->id);
        $lines = $this->lines($user, $payload, true);
        $rawLines = array_values($payload['lines']);
        $method = $payload['payment_method'] ?? 'cash';
        if (! in_array($method, ['cash', 'bank', 'credit'], true)) {
            throw ValidationException::withMessages(['payment_method' => 'Choose cash, bank, or credit.']);
        }

        return DB::transaction(function () use ($user, $payload, $branch, $location, $lines, $rawLines, $method) {
            $subtotal = \Brick\Math\BigDecimal::zero();
            $tax = \Brick\Math\BigDecimal::zero();
            $parsed = [];
            foreach ($lines as $index => $line) {
                $raw = is_array($rawLines[$index] ?? null) ? $rawLines[$index] : [];
                $percent = Dec::of($raw['tax_percent'] ?? 0);
                if ($percent->isNegative()) {
                    throw ValidationException::withMessages(['tax_percent' => 'Tax cannot be negative.']);
                }
                $net = Dec::of($line['qty'])->multipliedBy(Dec::of($line['unit_cost']));
                $taxPart = $net->multipliedBy($percent)->dividedBy(100, 2, \Brick\Math\RoundingMode::HALF_UP);
                $subtotal = $subtotal->plus($net);
                $tax = $tax->plus($taxPart);
                $parsed[] = ['line' => $line, 'raw' => $raw, 'percent' => $percent, 'line_total' => $net->plus($taxPart)];
            }
            $total = $subtotal->plus($tax);
            $paid = array_key_exists('paid', $payload) && $payload['paid'] !== '' && $payload['paid'] !== null
                ? Dec::of($payload['paid'])
                : ($method === 'credit' ? \Brick\Math\BigDecimal::zero() : $total);
            if ($paid->isNegative() || $paid->isGreaterThan($total)) {
                throw ValidationException::withMessages(['paid' => 'Paid amount cannot be more than the total.']);
            }

            $supplierId = null;
            if (! empty($payload['supplier_client_uuid'])) {
                $supplier = \App\Models\Supplier::query()
                    ->where('company_id', $user->company_id)
                    ->where('client_uuid', $payload['supplier_client_uuid'])
                    ->first();
                $supplierId = $supplier?->id;
            }

            $doc = Purchase::create([
                'company_id' => $user->company_id,
                'client_uuid' => $payload['client_uuid'],
                'branch_id' => $branch->id,
                'supplier_id' => $supplierId,
                'supplier_name' => $this->nullableText($payload, 'supplier_name'),
                'invoice_no' => $this->nullableText($payload, 'invoice_no'),
                'occurred_at' => $this->occurredAt($payload),
                'payment_method' => $method,
                'paid' => Dec::money($paid),
                'subtotal' => Dec::money($subtotal),
                'tax' => Dec::money($tax),
                'total' => Dec::money($total),
                'note' => $this->nullableText($payload, 'note'),
                'update_cost' => filter_var($payload['update_cost'] ?? true, FILTER_VALIDATE_BOOLEAN),
                'created_by' => $user->id,
            ]);

            $pairs = [];
            foreach ($parsed as $row) {
                $product = $row['line']['product'];
                if ($product->track_stock) {
                    $this->inventory->receive($this->spec(
                        $user,
                        $branch->id,
                        $location?->id,
                        $product,
                        InventoryEventType::PURCHASE,
                        $doc,
                        $payload,
                    ), [[
                        'qty' => $row['line']['qty'],
                        'unit_cost' => $row['line']['unit_cost'],
                    ]]);
                    $pairs[] = [$branch->id, $product->id];
                }
                if ($doc->update_cost) {
                    $product->purchase_price = Dec::money($row['line']['unit_cost']);
                }
                foreach (['new_sale_price' => 'sale_price', 'new_wholesale' => 'wholesale_price'] as $from => $to) {
                    $value = $row['raw'][$from] ?? null;
                    if ($value !== null && $value !== '' && is_numeric($value) && (float) $value >= 0) {
                        $product->{$to} = Dec::money($value);
                    }
                }
                $product->save();
                $expiry = trim((string) ($row['raw']['expiry'] ?? ''));
                PurchaseLine::create([
                    'purchase_id' => $doc->id,
                    'product_id' => $product->id,
                    'qty' => $row['line']['qty'],
                    'unit_cost' => $row['line']['unit_cost'],
                    'tax_percent' => Dec::money($row['percent']),
                    'line_total' => Dec::money($row['line_total']),
                    'new_sale_price' => $this->optionalMoney($row['raw'], 'new_sale_price'),
                    'new_wholesale' => $this->optionalMoney($row['raw'], 'new_wholesale'),
                    'batch_no' => $this->nullableText($row['raw'], 'batch_no'),
                    'expiry' => $expiry === '' ? null : Carbon::parse($expiry)->toDateString(),
                ]);
            }

            return $this->present($user, $doc->load(['lines.product', 'branch']), 'purchase', $pairs, false);
        });
    }

    public function purchaseReturn(User $user, array $payload): array
    {
        $this->assertUuid($payload);
        $existing = PurchaseReturn::query()
            ->with(['lines.product', 'branch'])
            ->where('company_id', $user->company_id)
            ->where('client_uuid', $payload['client_uuid'])
            ->first();
        if ($existing) {
            return $this->presentExisting($user, $existing, 'purchase_return');
        }

        $branch = $this->lookup->branch($user->company_id, $payload);
        $location = $this->optionalLocation($user, $payload, $branch->id);
        $lines = $this->lines($user, $payload, false);

        return DB::transaction(function () use ($user, $payload, $branch, $location, $lines) {
            $doc = PurchaseReturn::create([
                'company_id' => $user->company_id,
                'client_uuid' => $payload['client_uuid'],
                'branch_id' => $branch->id,
                'supplier_name' => $this->nullableText($payload, 'supplier_name'),
                'refund_method' => in_array($payload['refund_method'] ?? 'payable', ['payable', 'cash'], true) ? ($payload['refund_method'] ?? 'payable') : 'payable',
                'source_client_uuid' => $this->nullableText($payload, 'source_client_uuid'),
                'note' => $this->nullableText($payload, 'note'),
                'occurred_at' => $this->occurredAt($payload),
                'total' => 0,
                'created_by' => $user->id,
            ]);
            $pairs = [];
            $total = \Brick\Math\BigDecimal::zero();
            foreach ($lines as $line) {
                $issued = $this->inventory->issue($this->spec(
                    $user,
                    $branch->id,
                    $location?->id,
                    $line['product'],
                    InventoryEventType::PURCHASE_RETURN,
                    $doc,
                    $payload,
                ) + ['qty' => $line['qty']]);
                $value = Dec::of($issued['event']->value)->abs();
                $total = $total->plus($value);
                PurchaseReturnLine::create([
                    'purchase_return_id' => $doc->id,
                    'product_id' => $line['product']->id,
                    'qty' => $line['qty'],
                    'unit_cost' => Dec::cost($issued['event']->unit_cost),
                    'line_total' => Dec::money($value),
                ]);
                $pairs[] = [$branch->id, $line['product']->id];
            }
            $doc->total = Dec::money($total);
            $doc->save();

            return $this->present($user, $doc->load(['lines.product', 'branch']), 'purchase_return', $pairs, false);
        });
    }

    public function sale(User $user, array $payload): array
    {
        $this->assertUuid($payload);
        $existing = Sale::query()
            ->with(['lines.product', 'branch'])
            ->where('company_id', $user->company_id)
            ->where('client_uuid', $payload['client_uuid'])
            ->first();
        if ($existing) {
            return $this->presentExisting($user, $existing, 'sale');
        }

        $branch = $this->lookup->branch($user->company_id, $payload);
        $location = $this->optionalLocation($user, $payload, $branch->id);
        $lines = $this->saleLines($user, $payload);
        $method = in_array($payload['payment_method'] ?? 'cash', ['cash', 'bank', 'credit'], true) ? ($payload['payment_method'] ?? 'cash') : 'cash';

        return DB::transaction(function () use ($user, $payload, $branch, $location, $lines, $method) {
            $doc = Sale::create([
                'company_id' => $user->company_id,
                'client_uuid' => $payload['client_uuid'],
                'branch_id' => $branch->id,
                'party_name' => $this->nullableText($payload, 'party_name'),
                'invoice_no' => $this->nullableText($payload, 'invoice_no'),
                'note' => $this->nullableText($payload, 'note'),
                'occurred_at' => $this->occurredAt($payload),
                'payment_method' => $method,
                'paid' => 0,
                'total' => 0,
                'created_by' => $user->id,
            ]);
            $pairs = [];
            $total = BigDecimal::zero();
            foreach ($lines as $line) {
                $gross = Dec::of($line['unit_price'])->multipliedBy(Dec::of($line['qty']))->minus(Dec::of($line['discount']));
                if ($gross->isNegative()) {
                    $gross = BigDecimal::zero();
                }
                if ($line['is_return']) {
                    $gross = $gross->negated();
                }
                $total = $total->plus($gross);
                $unitCost = $line['unit_cost'];
                $product = $line['product'];
                if ($product && $product->track_stock) {
                    if ($line['is_return']) {
                        $this->inventory->receive($this->spec(
                            $user,
                            $branch->id,
                            $location?->id,
                            $product,
                            InventoryEventType::SALE_RETURN,
                            $doc,
                            $payload,
                        ), [['qty' => (string) $line['qty'], 'unit_cost' => (string) $unitCost]]);
                    } else {
                        $issued = $this->inventory->issue($this->spec(
                            $user,
                            $branch->id,
                            $location?->id,
                            $product,
                            InventoryEventType::SALE,
                            $doc,
                            $payload,
                        ) + ['qty' => $line['qty']]);
                        $unitCost = Dec::cost($issued['event']->unit_cost);
                    }
                    $pairs[] = [$branch->id, $product->id];
                }
                SaleLine::create([
                    'sale_id' => $doc->id,
                    'product_id' => $product?->id,
                    'line_name' => $line['name'],
                    'is_return' => $line['is_return'],
                    'discount' => $line['discount'],
                    'qty' => $line['qty'],
                    'unit_price' => $line['unit_price'],
                    'unit_cost' => $unitCost,
                    'line_total' => Dec::money($gross),
                ]);
            }
            $total = $total->plus(Dec::of(Dec::money($payload['tax'] ?? 0)))->minus(Dec::of(Dec::money($payload['order_discount'] ?? 0)));
            $doc->total = Dec::money($total);
            $doc->paid = $method === 'credit' ? Dec::money($payload['paid'] ?? 0) : $doc->total;
            $doc->save();

            return $this->present($user, $doc->load(['lines.product', 'branch']), 'sale', $pairs, false);
        });
    }

    public function summary(User $user, ?int $branchId): array
    {
        $products = Product::query()
            ->where('company_id', $user->company_id)
            ->where('track_stock', true)
            ->where('is_active', true)
            ->get();

        $balances = BranchStock::query()
            ->where('company_id', $user->company_id)
            ->when($branchId, fn ($q) => $q->where('branch_id', $branchId))
            ->get()
            ->groupBy('product_id');

        $inStock = 0;
        $lowStock = 0;
        $outOfStock = 0;
        $value = BigDecimal::zero();

        foreach ($products as $product) {
            $qty = BigDecimal::zero();
            foreach ($balances->get($product->id, collect()) as $row) {
                $qty = $qty->plus(Dec::of($row->qty_on_hand));
                $value = $value->plus(Dec::of($row->stock_value));
            }
            if ($qty->isGreaterThan(0)) {
                $inStock++;
                if (Dec::of($product->alert_qty)->isGreaterThan(0) && $qty->isLessThanOrEqualTo(Dec::of($product->alert_qty))) {
                    $lowStock++;
                }
            } else {
                $outOfStock++;
            }
        }

        $wastage = BigDecimal::zero();
        $events = InventoryEvent::query()
            ->where('company_id', $user->company_id)
            ->where('event_type', InventoryEventType::WRITE_OFF)
            ->when($branchId, fn ($q) => $q->where('branch_id', $branchId))
            ->where('occurred_at', '>=', now()->startOfMonth())
            ->get();
        foreach ($events as $event) {
            $wastage = $wastage->plus(Dec::of($event->value)->abs());
        }

        return [
            'products' => $products->count(),
            'in_stock' => $inStock,
            'low_stock' => $lowStock,
            'out_of_stock' => $outOfStock,
            'stock_value' => Dec::money($value),
            'wastage_this_month' => Dec::money($wastage),
        ];
    }

    public function balances(User $user, ?int $branchId, ?string $search): array
    {
        $branches = \App\Models\Branch::query()
            ->where('company_id', $user->company_id)
            ->when($branchId, fn ($q) => $q->where('id', $branchId))
            ->orderBy('name')
            ->get();

        $products = Product::query()
            ->with(['unit', 'category', 'brand'])
            ->where('company_id', $user->company_id)
            ->when($search, function ($query) use ($search) {
                $like = '%'.$search.'%';
                $query->where(function ($inner) use ($like) {
                    $inner->where('name_en', 'like', $like)
                        ->orWhere('name_ur', 'like', $like)
                        ->orWhere('code', 'like', $like)
                        ->orWhere('barcode', 'like', $like);
                });
            })
            ->orderBy('name_en')
            ->limit(500)
            ->get();

        $stock = BranchStock::query()
            ->where('company_id', $user->company_id)
            ->whereIn('product_id', $products->pluck('id'))
            ->whereIn('branch_id', $branches->pluck('id'))
            ->get()
            ->keyBy(fn ($row) => $row->branch_id.'-'.$row->product_id);

        $rows = [];
        foreach ($products as $product) {
            foreach ($branches as $branch) {
                $row = $stock->get($branch->id.'-'.$product->id);
                $qty = $row->qty_on_hand ?? '0.000';
                $rows[] = [
                    'product' => $product->toSyncArray(),
                    'branch_id' => $branch->id,
                    'branch_name' => $branch->name,
                    'qty_on_hand' => Dec::qty($qty),
                    'stock_value' => Dec::money($row->stock_value ?? 0),
                    'alert' => $this->alertState($product, $qty),
                ];
            }
        }

        return $rows;
    }

    public function eventQuery(User $user, array $filters)
    {
        return InventoryEvent::query()
            ->with(['product', 'branch', 'operator', 'location', 'fromLocation', 'toLocation'])
            ->where('company_id', $user->company_id)
            ->when(! empty($filters['branch_id']), fn ($q) => $q->where('branch_id', $filters['branch_id']))
            ->when(empty($filters['branch_id']) && ! empty($filters['branch_client_uuid']), function ($q) use ($filters) {
                $q->whereHas('branch', fn ($branch) => $branch->where('client_uuid', $filters['branch_client_uuid']));
            })
            ->when(! empty($filters['product_id']), fn ($q) => $q->where('product_id', $filters['product_id']))
            ->when(empty($filters['product_id']) && ! empty($filters['product_client_uuid']), function ($q) use ($filters) {
                $q->whereHas('product', fn ($product) => $product->where('client_uuid', $filters['product_client_uuid']));
            })
            ->when(! empty($filters['event_type']), fn ($q) => $q->where('event_type', $filters['event_type']))
            ->when(! empty($filters['from']), fn ($q) => $q->where('occurred_at', '>=', Carbon::parse($filters['from'])->startOfDay()))
            ->when(! empty($filters['to']), fn ($q) => $q->where('occurred_at', '<=', Carbon::parse($filters['to'])->endOfDay()))
            ->when(! empty($filters['q']), function ($q) use ($filters) {
                $like = '%'.$filters['q'].'%';
                $q->where(function ($inner) use ($like) {
                    $inner->where('reason', 'like', $like)
                        ->orWhere('source_type', 'like', $like)
                        ->orWhere('source_uuid', 'like', $like);
                });
            })
            ->orderByDesc('occurred_at')
            ->orderByDesc('id');
    }

    private function present(User $user, $doc, string $sourceType, array $pairs, bool $idempotent): array
    {
        $events = InventoryEvent::query()
            ->with(['product', 'branch', 'operator', 'location', 'fromLocation', 'toLocation'])
            ->where('company_id', $user->company_id)
            ->where('source_uuid', $doc->client_uuid)
            ->orderBy('id')
            ->get();

        return [
            'idempotent' => $idempotent,
            'document' => $doc->toSyncArray(),
            'events' => $events->map->toSyncArray()->values(),
        ] + $this->inventory->snapshot($user->company_id, $pairs);
    }

    private function presentExisting(User $user, $doc, string $sourceType): array
    {
        $pairs = [];
        foreach ($doc->lines as $line) {
            if ($sourceType === 'stock_transfer') {
                $pairs[] = [$doc->from_branch_id, $line->product_id];
                $pairs[] = [$doc->to_branch_id, $line->product_id];
            } else {
                $pairs[] = [$doc->branch_id, $line->product_id];
            }
        }

        return $this->present($user, $doc, $sourceType, $pairs, true);
    }

    private function spec(User $user, int $branchId, ?int $locationId, Product $product, string $eventType, $doc, array $payload): array
    {
        if (! $product->track_stock) {
            throw ValidationException::withMessages(['product_id' => $product->name_en.' does not track stock.']);
        }

        return [
            'company_id' => $user->company_id,
            'branch_id' => $branchId,
            'product_id' => $product->id,
            'location_id' => $locationId,
            'event_type' => $eventType,
            'source_type' => match ($eventType) {
                InventoryEventType::TRANSFER_IN, InventoryEventType::TRANSFER_OUT => 'stock_transfer',
                InventoryEventType::WRITE_OFF => 'stock_write_off',
                InventoryEventType::PURCHASE => 'purchase',
                InventoryEventType::PURCHASE_RETURN => 'purchase_return',
                InventoryEventType::SALE, InventoryEventType::SALE_RETURN => 'sale',
                default => 'stock_adjustment',
            },
            'source_id' => $doc->id,
            'source_uuid' => $doc->client_uuid,
            'reason' => $doc->reason ?? ($doc->invoice_no ?? null),
            'operator_id' => $user->id,
            'occurred_at' => $doc->occurred_at,
        ];
    }

    private function saleLines(User $user, array $payload): array
    {
        $lines = $payload['lines'] ?? null;
        if (! is_array($lines) || count($lines) === 0) {
            throw ValidationException::withMessages(['lines' => 'Add at least one product line.']);
        }

        $parsed = [];
        foreach ($lines as $index => $line) {
            if (! is_array($line)) {
                throw ValidationException::withMessages(['lines' => 'Line '.($index + 1).' is invalid.']);
            }
            $qty = Dec::qty($line['qty'] ?? 0);
            if (Dec::cmp($qty, '0') <= 0) {
                throw ValidationException::withMessages(['qty' => 'Quantity must be greater than zero.']);
            }
            $product = null;
            if (! empty($line['product_client_uuid']) || ! empty($line['product_id'])) {
                $product = $this->lookup->product($user->company_id, $line);
            }
            $name = trim((string) ($line['name'] ?? ''));
            if ($product === null && $name === '') {
                throw ValidationException::withMessages(['lines' => 'Line '.($index + 1).' needs a product or a name.']);
            }
            $parsed[] = [
                'product' => $product,
                'name' => $name !== '' ? $name : $product->name_en,
                'qty' => $qty,
                'unit_price' => Dec::money($line['unit_price'] ?? $product?->sale_price ?? 0),
                'discount' => Dec::money($line['discount'] ?? 0),
                'is_return' => filter_var($line['is_return'] ?? false, FILTER_VALIDATE_BOOLEAN),
                'unit_cost' => Dec::cost($line['unit_cost'] ?? $product?->purchase_price ?? 0),
            ];
        }

        return $parsed;
    }

    private function lines(User $user, array $payload, bool $requireCost): array
    {
        $lines = $payload['lines'] ?? null;
        if (! is_array($lines) || count($lines) === 0) {
            throw ValidationException::withMessages(['lines' => 'Add at least one product line.']);
        }

        $parsed = [];
        $seen = [];
        foreach ($lines as $index => $line) {
            if (! is_array($line)) {
                throw ValidationException::withMessages(['lines' => 'Line '.($index + 1).' is invalid.']);
            }
            $product = $this->lookup->product($user->company_id, $line);
            if (isset($seen[$product->id])) {
                throw ValidationException::withMessages(['lines' => $product->name_en.' is on this document twice.']);
            }
            $seen[$product->id] = true;
            $qty = Dec::qty($line['qty'] ?? 0);
            if (Dec::cmp($qty, '0') <= 0) {
                throw ValidationException::withMessages(['qty' => 'Quantity must be greater than zero.']);
            }
            $unitCost = null;
            if ($requireCost) {
                if (! isset($line['unit_cost']) || $line['unit_cost'] === '') {
                    throw ValidationException::withMessages(['unit_cost' => 'Unit cost is required when stock comes in.']);
                }
                if (Dec::of($line['unit_cost'])->isNegative()) {
                    throw ValidationException::withMessages(['unit_cost' => 'Unit cost cannot be negative.']);
                }
                $unitCost = Dec::cost($line['unit_cost']);
            }
            $parsed[] = ['product' => $product, 'qty' => $qty, 'unit_cost' => $unitCost];
        }

        return $parsed;
    }

    private function optionalLocation(User $user, array $payload, int $branchId): ?\App\Models\Location
    {
        if (empty($payload['location_id']) && empty($payload['location_client_uuid'])) {
            return null;
        }
        $location = $this->lookup->location($user->company_id, $payload);
        if ($location->branch_id !== $branchId) {
            throw ValidationException::withMessages(['location_id' => 'That godown belongs to another branch.']);
        }

        return $location;
    }

    private function alertState(Product $product, mixed $qty): string
    {
        $quantity = Dec::of($qty);
        if ($quantity->isLessThanOrEqualTo(0)) {
            return 'out';
        }
        if (Dec::of($product->alert_qty)->isGreaterThan(0) && $quantity->isLessThanOrEqualTo(Dec::of($product->alert_qty))) {
            return 'low';
        }

        return 'in';
    }

    private function occurredAt(array $payload): Carbon
    {
        // Eloquent writes the wall-clock value without converting zones, so normalise first.
        return empty($payload['occurred_at']) ? now() : Carbon::parse($payload['occurred_at'])->setTimezone(config('app.timezone'));
    }

    private function assertUuid(array $payload): void
    {
        $uuid = $payload['client_uuid'] ?? null;
        if (! is_string($uuid) || ! Str::isUuid($uuid)) {
            throw ValidationException::withMessages(['client_uuid' => 'A client UUID is required.']);
        }
    }

    private function optionalMoney(array $payload, string $key): ?string
    {
        $value = $payload[$key] ?? null;
        if ($value === null || $value === '' || ! is_numeric($value)) {
            return null;
        }

        return Dec::money($value);
    }

    private function nullableText(array $payload, string $key): ?string
    {
        if (! array_key_exists($key, $payload) || $payload[$key] === null) {
            return null;
        }
        $value = trim((string) $payload[$key]);

        return $value === '' ? null : $value;
    }
}
