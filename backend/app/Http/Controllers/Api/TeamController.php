<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Branch;
use App\Models\Location;
use App\Models\User;
use App\Services\CatalogService;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function __construct(private readonly CatalogService $catalog) {}

    public function branches(Request $request)
    {
        $rows = Branch::query()->where('company_id', $request->user()->company_id)->orderByDesc('is_main')->orderBy('name')->get();

        return response()->json(['data' => $rows->map->toSyncArray()->values()]);
    }

    public function storeBranch(Request $request)
    {
        $result = $this->catalog->branch($request->user(), 'create', $request->all());

        return response()->json($result, empty($result['idempotent']) ? 201 : 200);
    }

    public function locations(Request $request)
    {
        $rows = Location::query()->with('branch')->where('company_id', $request->user()->company_id)->orderBy('name')->get();

        return response()->json(['data' => $rows->map->toSyncArray()->values()]);
    }

    public function storeLocation(Request $request)
    {
        $result = $this->catalog->location($request->user(), 'create', $request->all());

        return response()->json($result, empty($result['idempotent']) ? 201 : 200);
    }

    public function users(Request $request)
    {
        $rows = User::query()->where('company_id', $request->user()->company_id)->orderBy('name')->get();

        return response()->json(['data' => $rows->map->toApiArray()->values()]);
    }

    public function storeUser(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:160', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
            'role' => ['required', 'in:manager,cashier'],
            'phone' => ['nullable', 'string', 'max:40'],
        ]);

        $user = User::create([
            'company_id' => $request->user()->company_id,
            'name' => $data['name'],
            'username' => $data['name'],
            'email' => $data['email'],
            'password' => $data['password'],
            'role' => $data['role'],
            'phone' => $data['phone'] ?? null,
            'is_active' => true,
        ]);

        return response()->json(['data' => $user->toApiArray()], 201);
    }
}
