<?php

namespace App\Services;

use App\Models\Branch;
use App\Models\Brand;
use App\Models\Category;
use App\Models\Location;
use App\Models\Product;
use App\Models\Unit;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Validation\ValidationException;

class CompanyLookup
{
    public function product(int $companyId, array $ref): Product
    {
        return $this->required(Product::class, $companyId, $ref, 'product_id', 'product_client_uuid', 'Product');
    }

    public function branch(int $companyId, array $ref, string $idKey = 'branch_id', string $uuidKey = 'branch_client_uuid'): Branch
    {
        return $this->required(Branch::class, $companyId, $ref, $idKey, $uuidKey, 'Branch');
    }

    public function location(int $companyId, array $ref, string $idKey = 'location_id', string $uuidKey = 'location_client_uuid'): Location
    {
        return $this->required(Location::class, $companyId, $ref, $idKey, $uuidKey, 'Godown');
    }

    public function unit(int $companyId, array $ref): Unit
    {
        return $this->required(Unit::class, $companyId, $ref, 'unit_id', 'unit_client_uuid', 'Unit');
    }

    public function category(int $companyId, array $ref): ?Category
    {
        return $this->optional(Category::class, $companyId, $ref, 'category_id', 'category_client_uuid', 'Category');
    }

    public function parentCategory(int $companyId, array $ref): ?Category
    {
        return $this->optional(Category::class, $companyId, $ref, 'parent_id', 'parent_client_uuid', 'Parent category');
    }

    public function brand(int $companyId, array $ref): ?Brand
    {
        return $this->optional(Brand::class, $companyId, $ref, 'brand_id', 'brand_client_uuid', 'Brand');
    }

    private function required(string $class, int $companyId, array $ref, string $idKey, string $uuidKey, string $label): Model
    {
        $row = $this->optional($class, $companyId, $ref, $idKey, $uuidKey, $label);
        if (! $row) {
            throw ValidationException::withMessages([$idKey => $label.' is required.']);
        }

        return $row;
    }

    private function optional(string $class, int $companyId, array $ref, string $idKey, string $uuidKey, string $label): ?Model
    {
        if (empty($ref[$idKey]) && empty($ref[$uuidKey])) {
            return null;
        }

        $query = $class::query()->where('company_id', $companyId);
        $row = ! empty($ref[$idKey])
            ? (clone $query)->where('id', $ref[$idKey])->first()
            : (clone $query)->where('client_uuid', $ref[$uuidKey])->first();

        if (! $row) {
            throw ValidationException::withMessages([$idKey => $label.' was not found.']);
        }

        return $row;
    }
}
