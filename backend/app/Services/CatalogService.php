<?php

namespace App\Services;

use App\Exceptions\SyncConflict;
use App\Models\Branch;
use App\Models\Brand;
use App\Models\Category;
use App\Models\InventoryEvent;
use App\Models\Location;
use App\Models\LocationStock;
use App\Models\Product;
use App\Models\SyncTombstone;
use App\Models\Unit;
use App\Models\User;
use App\Support\Dec;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class CatalogService
{
    public function __construct(
        private readonly CompanyLookup $lookup,
        private readonly CompanyBootstrapService $bootstrap,
    ) {}

    public function apply(User $user, string $entity, string $action, array $payload): array
    {
        return match ($entity) {
            'unit' => $this->unit($user, $action, $payload),
            'category' => $this->category($user, $action, $payload),
            'brand' => $this->brand($user, $action, $payload),
            'product' => $this->product($user, $action, $payload),
            'branch' => $this->branch($user, $action, $payload),
            'location' => $this->location($user, $action, $payload),
            default => throw ValidationException::withMessages(['entity' => 'Unknown catalog entity.']),
        };
    }

    public function unit(User $user, string $action, array $payload): array
    {
        return $this->saveMaster($user, Unit::class, 'unit', $action, $payload, function (Unit $row, array $payload) {
            $row->fill([
                'name_en' => $this->requiredText($payload, 'name_en', 'Unit name'),
                'name_ur' => $this->nullableText($payload, 'name_ur'),
                'short_name' => $this->requiredText($payload, 'short_name', 'Short name'),
            ]);
        }, function (Unit $row) use ($user) {
            if (Product::query()->where('company_id', $user->company_id)->where('unit_id', $row->id)->exists()) {
                throw ValidationException::withMessages(['unit' => 'This unit is used by a product.']);
            }
        });
    }

    public function category(User $user, string $action, array $payload): array
    {
        return $this->saveMaster($user, Category::class, 'category', $action, $payload, function (Category $row, array $payload) use ($user) {
            $parent = $this->lookup->parentCategory($user->company_id, $payload);
            if ($parent && $row->exists && $parent->id === $row->id) {
                throw ValidationException::withMessages(['parent_id' => 'A category cannot be its own parent.']);
            }
            if ($parent && $row->exists) {
                $cursor = $parent;
                while ($cursor) {
                    if ($cursor->id === $row->id) {
                        throw ValidationException::withMessages(['parent_id' => 'That parent would create a cycle.']);
                    }
                    $cursor = $cursor->parent_id ? Category::query()->find($cursor->parent_id) : null;
                }
            }
            $row->fill([
                'parent_id' => $parent?->id,
                'name_en' => $this->requiredText($payload, 'name_en', 'Category name'),
                'name_ur' => $this->nullableText($payload, 'name_ur'),
                'code' => $this->nullableText($payload, 'code'),
                'is_active' => array_key_exists('is_active', $payload) ? (bool) $payload['is_active'] : true,
            ]);
        }, function (Category $row) use ($user) {
            if (Category::query()->where('parent_id', $row->id)->exists()) {
                throw ValidationException::withMessages(['category' => 'This category has child categories.']);
            }
            if (Product::query()->where('company_id', $user->company_id)->where('category_id', $row->id)->exists()) {
                throw ValidationException::withMessages(['category' => 'This category is used by a product.']);
            }
        }, ['parent']);
    }

    public function brand(User $user, string $action, array $payload): array
    {
        return $this->saveMaster($user, Brand::class, 'brand', $action, $payload, function (Brand $row, array $payload) {
            $row->fill([
                'name_en' => $this->requiredText($payload, 'name_en', 'Brand name'),
                'name_ur' => $this->nullableText($payload, 'name_ur'),
                'code' => $this->nullableText($payload, 'code'),
                'is_active' => array_key_exists('is_active', $payload) ? (bool) $payload['is_active'] : true,
            ]);
        }, function (Brand $row) use ($user) {
            if (Product::query()->where('company_id', $user->company_id)->where('brand_id', $row->id)->exists()) {
                throw ValidationException::withMessages(['brand' => 'This brand is used by a product.']);
            }
        });
    }

    public function product(User $user, string $action, array $payload): array
    {
        return $this->saveMaster($user, Product::class, 'product', $action, $payload, function (Product $row, array $payload) use ($user) {
            foreach (['purchase_price', 'sale_price', 'wholesale_price', 'alert_qty'] as $moneyKey) {
                if (isset($payload[$moneyKey]) && Dec::of($payload[$moneyKey])->isNegative()) {
                    throw ValidationException::withMessages([$moneyKey => 'Amount cannot be negative.']);
                }
            }
            $unit = $this->lookup->unit($user->company_id, $payload);
            $category = $this->lookup->category($user->company_id, $payload);
            $brand = $this->lookup->brand($user->company_id, $payload);
            $code = $this->nullableText($payload, 'code');
            if ($code) {
                $dupe = Product::query()
                    ->where('company_id', $user->company_id)
                    ->where('code', $code)
                    ->when($row->exists, fn ($q) => $q->where('id', '!=', $row->id))
                    ->exists();
                if ($dupe) {
                    throw ValidationException::withMessages(['code' => 'That product code is already used.']);
                }
            }
            $barcode = $this->nullableText($payload, 'barcode');
            if ($barcode) {
                $dupe = Product::query()
                    ->where('company_id', $user->company_id)
                    ->where('barcode', $barcode)
                    ->when($row->exists, fn ($q) => $q->where('id', '!=', $row->id))
                    ->exists();
                if ($dupe) {
                    throw ValidationException::withMessages(['barcode' => 'That barcode is already used.']);
                }
            }

            $row->fill([
                'code' => $code ?: ($row->code ?: 'TMP-'.$payload['client_uuid']),
                'barcode' => $barcode,
                'name_en' => $this->requiredText($payload, 'name_en', 'Product name'),
                'name_ur' => $this->nullableText($payload, 'name_ur'),
                'category_id' => $category?->id,
                'brand_id' => $brand?->id,
                'unit_id' => $unit->id,
                'purchase_price' => Dec::money($payload['purchase_price'] ?? 0),
                'sale_price' => Dec::money($payload['sale_price'] ?? 0),
                'wholesale_price' => Dec::money($payload['wholesale_price'] ?? 0),
                'alert_qty' => Dec::qty($payload['alert_qty'] ?? 0),
                'track_stock' => array_key_exists('track_stock', $payload) ? (bool) $payload['track_stock'] : true,
                'is_active' => array_key_exists('is_active', $payload) ? (bool) $payload['is_active'] : true,
            ]);
        }, function (Product $row) {
            if (InventoryEvent::query()->where('product_id', $row->id)->exists()) {
                throw ValidationException::withMessages(['product' => 'This product already has stock history.']);
            }
        }, ['unit', 'category', 'brand']);
    }

    public function branch(User $user, string $action, array $payload): array
    {
        $this->assertUuid($payload);
        if ($action === 'delete') {
            throw ValidationException::withMessages(['branch' => 'Branches are not deleted in this version.']);
        }

        $existing = Branch::query()
            ->where('company_id', $user->company_id)
            ->where('client_uuid', $payload['client_uuid'])
            ->first();

        if ($existing && $action === 'create') {
            return ['record' => $existing->load('locations')->toSyncArray(), 'idempotent' => true];
        }

        if ($existing) {
            $this->guardConflict($existing, $payload);
            $existing->fill([
                'name' => $this->requiredText($payload, 'name', 'Branch name'),
                'code' => $this->nullableText($payload, 'code'),
                'is_active' => array_key_exists('is_active', $payload) ? (bool) $payload['is_active'] : $existing->is_active,
            ])->save();

            return ['record' => $existing->fresh()->toSyncArray(), 'idempotent' => false];
        }

        $branch = $this->bootstrap->makeBranch(
            $user->company_id,
            $this->requiredText($payload, 'name', 'Branch name'),
            $this->nullableText($payload, 'code'),
            false,
            $payload['client_uuid'],
            $payload['location_client_uuid'] ?? null,
        );

        return ['record' => $branch->fresh()->toSyncArray(), 'idempotent' => false];
    }

    public function location(User $user, string $action, array $payload): array
    {
        $this->assertUuid($payload);
        $existing = Location::query()
            ->with('branch')
            ->where('company_id', $user->company_id)
            ->where('client_uuid', $payload['client_uuid'])
            ->first();

        if ($action === 'delete') {
            if (! $existing) {
                return ['record' => null, 'idempotent' => true];
            }
            $this->guardConflict($existing, $payload);
            if ($existing->is_default) {
                throw ValidationException::withMessages(['location' => 'The default godown stays with the branch.']);
            }
            if (LocationStock::query()->where('location_id', $existing->id)->where('qty_on_hand', '!=', 0)->exists()) {
                throw ValidationException::withMessages(['location' => 'This godown still holds stock.']);
            }
            $this->tombstone($user, 'location', $existing);
            $existing->delete();

            return ['record' => null, 'idempotent' => false];
        }

        if ($existing && $action === 'create') {
            return ['record' => $existing->toSyncArray(), 'idempotent' => true];
        }

        $branch = $this->lookup->branch($user->company_id, $payload);

        if ($existing) {
            $this->guardConflict($existing, $payload);
            $existing->fill([
                'name' => $this->requiredText($payload, 'name', 'Godown name'),
                'is_active' => array_key_exists('is_active', $payload) ? (bool) $payload['is_active'] : $existing->is_active,
            ])->save();

            return ['record' => $existing->fresh()->load('branch')->toSyncArray(), 'idempotent' => false];
        }

        $location = Location::create([
            'company_id' => $user->company_id,
            'branch_id' => $branch->id,
            'client_uuid' => $payload['client_uuid'],
            'name' => $this->requiredText($payload, 'name', 'Godown name'),
            'is_default' => false,
            'is_active' => true,
        ]);

        return ['record' => $location->load('branch')->toSyncArray(), 'idempotent' => false];
    }

    private function saveMaster(User $user, string $class, string $entity, string $action, array $payload, callable $fill, ?callable $guardDelete = null, array $with = []): array
    {
        $this->assertUuid($payload);

        /** @var Model|null $existing */
        $existing = $class::query()
            ->where('company_id', $user->company_id)
            ->where('client_uuid', $payload['client_uuid'])
            ->first();

        if ($action === 'delete') {
            if (! $existing) {
                return ['record' => null, 'idempotent' => true];
            }
            $this->guardConflict($existing, $payload);
            if ($guardDelete) {
                $guardDelete($existing);
            }
            $this->tombstone($user, $entity, $existing);
            $existing->delete();

            return ['record' => null, 'idempotent' => false];
        }

        if ($existing && $action === 'create') {
            return ['record' => $existing->load($with)->toSyncArray(), 'idempotent' => true];
        }

        if ($existing) {
            $this->guardConflict($existing, $payload);
        }

        $row = $existing ?: new $class([
            'company_id' => $user->company_id,
            'client_uuid' => $payload['client_uuid'],
        ]);

        $fill($row, $payload);
        $row->save();

        if ($entity === 'product' && str_starts_with((string) $row->code, 'TMP-')) {
            $row->code = 'PRD-'.str_pad((string) $row->id, 4, '0', STR_PAD_LEFT);
            $row->save();
        }

        return ['record' => $row->fresh()->load($with)->toSyncArray(), 'idempotent' => false];
    }

    private function guardConflict(Model $existing, array $payload): void
    {
        if (empty($payload['base_updated_at']) || ! $existing->updated_at) {
            return;
        }

        $base = Carbon::parse($payload['base_updated_at']);
        if ($existing->updated_at->gt($base)) {
            $existing->loadMissing([]);
            throw new SyncConflict(method_exists($existing, 'toSyncArray') ? $existing->fresh()->toSyncArray() : $existing->toArray());
        }
    }

    private function tombstone(User $user, string $entity, Model $row): void
    {
        SyncTombstone::create([
            'company_id' => $user->company_id,
            'entity' => $entity,
            'record_id' => $row->getKey(),
            'client_uuid' => $row->client_uuid ?? null,
        ]);
    }

    private function assertUuid(array $payload): void
    {
        $uuid = $payload['client_uuid'] ?? null;
        if (! is_string($uuid) || ! Str::isUuid($uuid)) {
            throw ValidationException::withMessages(['client_uuid' => 'A client UUID is required.']);
        }
    }

    private function requiredText(array $payload, string $key, string $label): string
    {
        $value = trim((string) ($payload[$key] ?? ''));
        if ($value === '') {
            throw ValidationException::withMessages([$key => $label.' is required.']);
        }

        return $value;
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
