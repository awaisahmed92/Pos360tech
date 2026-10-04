<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: DejaVu Sans, sans-serif; font-size: 11px; color: #14221f; }
        h1 { font-size: 18px; margin: 0 0 4px; }
        p { margin: 0 0 12px; color: #52615e; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border-bottom: 1px solid #d7e3e0; padding: 5px 4px; text-align: left; }
        th { background: #0f766e; color: white; font-weight: 600; }
        .num { text-align: right; }
    </style>
</head>
<body>
    <h1>{{ $company->name }} — Inventory event ledger</h1>
    <p>Immutable stock movements. Location moves do not change the branch balance. FIFO cost is the cost recorded on each event.</p>
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Product</th>
                <th>Branch</th>
                <th>Type</th>
                <th class="num">Qty</th>
                <th class="num">Unit cost</th>
                <th class="num">Value</th>
                <th class="num">Balance</th>
                <th>Source</th>
                <th>Reason</th>
                <th>Operator</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($events as $event)
                <tr>
                    <td>{{ optional($event->occurred_at)->format('Y-m-d H:i') }}</td>
                    <td>{{ $event->product?->name_en }}</td>
                    <td>{{ $event->branch?->name }}</td>
                    <td>{{ str_replace('_', ' ', $event->event_type) }}</td>
                    <td class="num">{{ $event->qty }}</td>
                    <td class="num">{{ $event->unit_cost }}</td>
                    <td class="num">{{ $event->value }}</td>
                    <td class="num">{{ $event->running_balance }}</td>
                    <td>{{ $event->source_type }}</td>
                    <td>{{ $event->reason }}</td>
                    <td>{{ $event->operator?->name }}</td>
                </tr>
            @empty
                <tr><td colspan="11">No records found</td></tr>
            @endforelse
        </tbody>
    </table>
</body>
</html>
