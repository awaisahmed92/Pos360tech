<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\SyncService;
use Illuminate\Http\Request;

class SyncController extends Controller
{
    public function __construct(private readonly SyncService $sync) {}

    public function push(Request $request)
    {
        $data = $request->validate([
            'device_id' => ['required', 'string', 'max:100'],
            'device_name' => ['nullable', 'string', 'max:120'],
            'operations' => ['required', 'array'],
            'operations.*.entity' => ['required', 'string'],
            'operations.*.action' => ['nullable', 'string'],
            'operations.*.op_id' => ['nullable', 'string'],
            'operations.*.client_uuid' => ['nullable', 'string'],
            'operations.*.payload' => ['nullable', 'array'],
        ]);

        return response()->json($this->sync->push(
            $request->user(),
            $data['device_id'],
            $data['device_name'] ?? $request->header('X-Device-Name'),
            $data['operations'],
        ));
    }

    public function pull(Request $request)
    {
        $data = $request->validate([
            'device_id' => ['required', 'string', 'max:100'],
            'since' => ['nullable', 'date'],
        ]);

        return response()->json($this->sync->pull($request->user(), $data['since'] ?? null, $data['device_id']));
    }
}
