<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LocationMove;
use App\Models\StockAdjustment;
use App\Models\StockTransfer;
use App\Models\StockWriteOff;
use App\Services\StockDocumentService;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;

class StockController extends Controller
{
    public function __construct(private readonly StockDocumentService $stock) {}

    public function summary(Request $request)
    {
        return response()->json([
            'data' => $this->stock->summary($request->user(), $request->integer('branch_id') ?: null),
        ]);
    }

    public function balances(Request $request)
    {
        return response()->json([
            'data' => $this->stock->balances(
                $request->user(),
                $request->integer('branch_id') ?: null,
                $request->string('q')->toString() ?: null,
            ),
        ]);
    }

    public function events(Request $request)
    {
        $rows = $this->stock->eventQuery($request->user(), $request->all())->limit(500)->get();

        return response()->json(['data' => $rows->map->toSyncArray()->values()]);
    }

    public function exportCsv(Request $request)
    {
        $rows = $this->stock->eventQuery($request->user(), $request->all())->limit(5000)->get();

        return response()->streamDownload(function () use ($rows) {
            $out = fopen('php://output', 'w');
            fputcsv($out, ['Date', 'Product', 'Code', 'Branch', 'Type', 'Quantity', 'Unit cost', 'Value', 'Running balance', 'Source', 'Reason', 'Operator']);
            foreach ($rows as $event) {
                fputcsv($out, [
                    optional($event->occurred_at)->toDateTimeString(),
                    $event->product?->name_en,
                    $event->product?->code,
                    $event->branch?->name,
                    $event->event_type,
                    $event->qty,
                    $event->unit_cost,
                    $event->value,
                    $event->running_balance,
                    trim(($event->source_type ?? '').' '.($event->source_uuid ?? '')),
                    $event->reason,
                    $event->operator?->name,
                ]);
            }
            fclose($out);
        }, 'inventory-ledger.csv', ['Content-Type' => 'text/csv']);
    }

    public function exportPdf(Request $request)
    {
        $rows = $this->stock->eventQuery($request->user(), $request->all())->limit(5000)->get();
        $pdf = Pdf::loadView('stock.ledger', [
            'events' => $rows,
            'company' => $request->user()->company,
        ])->setPaper('a4', 'landscape');

        return $pdf->download('inventory-ledger.pdf');
    }

    public function adjustments(Request $request)
    {
        $rows = StockAdjustment::query()->with('lines.product')->where('company_id', $request->user()->company_id)->orderByDesc('id')->limit(200)->get();

        return response()->json(['data' => $rows->map->toSyncArray()->values()]);
    }

    public function storeAdjustment(Request $request)
    {
        return response()->json($this->stock->adjust($request->user(), $request->all()), 201);
    }

    public function transfers(Request $request)
    {
        $rows = StockTransfer::query()->with('lines.product')->where('company_id', $request->user()->company_id)->orderByDesc('id')->limit(200)->get();

        return response()->json(['data' => $rows->map->toSyncArray()->values()]);
    }

    public function storeTransfer(Request $request)
    {
        return response()->json($this->stock->transfer($request->user(), $request->all()), 201);
    }

    public function writeOffs(Request $request)
    {
        $rows = StockWriteOff::query()->with('lines.product')->where('company_id', $request->user()->company_id)->orderByDesc('id')->limit(200)->get();

        return response()->json(['data' => $rows->map->toSyncArray()->values()]);
    }

    public function storeWriteOff(Request $request)
    {
        return response()->json($this->stock->writeOff($request->user(), $request->all()), 201);
    }

    public function locationMoves(Request $request)
    {
        $rows = LocationMove::query()->with('lines.product')->where('company_id', $request->user()->company_id)->orderByDesc('id')->limit(200)->get();

        return response()->json(['data' => $rows->map->toSyncArray()->values()]);
    }

    public function storeLocationMove(Request $request)
    {
        return response()->json($this->stock->move($request->user(), $request->all()), 201);
    }
}
