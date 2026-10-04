<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Brand;
use App\Models\Category;
use App\Models\Product;
use App\Models\Unit;
use App\Services\CatalogService;
use Illuminate\Http\Request;

class CatalogController extends Controller
{
    public function __construct(private readonly CatalogService $catalog) {}

    public function units(Request $request)
    {
        $rows = Unit::query()->where('company_id', $request->user()->company_id)->orderBy('name_en')->get();

        return response()->json(['data' => $rows->map->toSyncArray()->values()]);
    }

    public function storeUnit(Request $request)
    {
        return $this->write($request, 'unit', 'create');
    }

    public function updateUnit(Request $request, int $id)
    {
        return $this->write($request, 'unit', 'update', $id, Unit::class);
    }

    public function destroyUnit(Request $request, int $id)
    {
        return $this->write($request, 'unit', 'delete', $id, Unit::class);
    }

    public function categories(Request $request)
    {
        $rows = Category::query()->with('parent')->where('company_id', $request->user()->company_id)->orderBy('name_en')->get();

        return response()->json(['data' => $rows->map->toSyncArray()->values()]);
    }

    public function storeCategory(Request $request)
    {
        return $this->write($request, 'category', 'create');
    }

    public function updateCategory(Request $request, int $id)
    {
        return $this->write($request, 'category', 'update', $id, Category::class);
    }

    public function destroyCategory(Request $request, int $id)
    {
        return $this->write($request, 'category', 'delete', $id, Category::class);
    }

    public function brands(Request $request)
    {
        $rows = Brand::query()->where('company_id', $request->user()->company_id)->orderBy('name_en')->get();

        return response()->json(['data' => $rows->map->toSyncArray()->values()]);
    }

    public function storeBrand(Request $request)
    {
        return $this->write($request, 'brand', 'create');
    }

    public function updateBrand(Request $request, int $id)
    {
        return $this->write($request, 'brand', 'update', $id, Brand::class);
    }

    public function destroyBrand(Request $request, int $id)
    {
        return $this->write($request, 'brand', 'delete', $id, Brand::class);
    }

    public function products(Request $request)
    {
        $search = $request->string('q')->toString();
        $rows = Product::query()
            ->with(['unit', 'category', 'brand'])
            ->where('company_id', $request->user()->company_id)
            ->when($search !== '', function ($query) use ($search) {
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

        return response()->json(['data' => $rows->map->toSyncArray()->values()]);
    }

    public function storeProduct(Request $request)
    {
        return $this->write($request, 'product', 'create');
    }

    public function updateProduct(Request $request, int $id)
    {
        return $this->write($request, 'product', 'update', $id, Product::class);
    }

    public function destroyProduct(Request $request, int $id)
    {
        return $this->write($request, 'product', 'delete', $id, Product::class);
    }

    private function write(Request $request, string $entity, string $action, ?int $id = null, ?string $class = null)
    {
        $payload = $request->all();
        if ($id && $class) {
            $row = $class::query()->where('company_id', $request->user()->company_id)->findOrFail($id);
            $payload['client_uuid'] = $row->client_uuid;
            $payload['base_updated_at'] = $payload['base_updated_at'] ?? optional($row->updated_at)->toJSON();
        }

        $result = $this->catalog->apply($request->user(), $entity, $action, $payload);
        $status = $action === 'create' && empty($result['idempotent']) ? 201 : 200;

        return response()->json($result, $status);
    }
}
