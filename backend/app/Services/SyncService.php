<?php

namespace App\Services;

use App\Exceptions\SyncConflict;
use App\Models\Branch;
use App\Models\Brand;
use App\Models\Category;
use App\Models\Cheque;
use App\Models\DayClose;
use App\Models\Area;
use App\Models\AttendanceMark;
use App\Models\BankAccount;
use App\Models\CreditRecovery;
use App\Models\Employee;
use App\Models\Expense;
use App\Models\ManufacturingProduct;
use App\Models\Party;
use App\Models\JournalEntry;
use App\Models\InventoryEvent;
use App\Models\InvestmentEntry;
use App\Models\InvestmentPartner;
use App\Models\LedgerAccount;
use App\Models\Purchase;
use App\Models\PurchaseOrder;
use App\Models\PurchasePayment;
use App\Models\PurchaseReturn;
use App\Models\SalaryPayment;
use App\Models\Sale;
use App\Models\ShopDocument;
use App\Models\Supplier;
use App\Models\Location;
use App\Models\LocationMove;
use App\Models\LocationStock;
use App\Models\Product;
use App\Models\BranchStock;
use App\Models\StockAdjustment;
use App\Models\StockLayer;
use App\Models\StockTransfer;
use App\Models\StockWriteOff;
use App\Models\SyncCursor;
use App\Models\SyncTombstone;
use App\Models\Unit;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Support\Carbon;
use Illuminate\Validation\ValidationException;

class SyncService
{
    public function __construct(
        private readonly CompanyBootstrapService $bootstrap,
        private readonly CatalogService $catalog,
        private readonly StockDocumentService $stock,
        private readonly MoneyService $money,
        private readonly TradeService $trade,
    ) {}

    public function push(User $user, string $deviceId, ?string $deviceName, array $operations): array
    {
        $this->bootstrap->touchDevice($user, $deviceId, $deviceName);
        $results = [];

        foreach ($operations as $operation) {
            $opId = $operation['op_id'] ?? null;
            try {
                if (! $user->managesStock()) {
                    throw ValidationException::withMessages([
                        'role' => 'You do not have permission to do that.',
                    ]);
                }
                $entity = (string) ($operation['entity'] ?? '');
                $action = (string) ($operation['action'] ?? 'create');
                $payload = is_array($operation['payload'] ?? null) ? $operation['payload'] : [];
                if (! empty($operation['client_uuid']) && empty($payload['client_uuid'])) {
                    $payload['client_uuid'] = $operation['client_uuid'];
                }

                $result = match (true) {
                    in_array($entity, ['stock_adjustment', 'stock_transfer', 'stock_write_off', 'location_move', 'purchase', 'purchase_return', 'sale'], true) => $this->stock->apply($user, $entity, $action, $payload),
                    in_array($entity, ['cheque', 'investment_partner', 'investment_entry', 'journal_entry', 'day_close'], true) => $this->money->apply($user, $entity, $action, $payload),
                    in_array($entity, ['ledger_account', 'bank_account', 'supplier', 'purchase_order', 'purchase_payment', 'party', 'area', 'credit_recovery', 'manufacturing_product', 'expense', 'employee', 'attendance', 'salary_payment', 'shop_settings', 'payment_method', 'estimate', 'sale_order', 'delivery_note'], true) => $this->trade->apply($user, $entity, $action, $payload),
                    default => $this->catalog->apply($user, $entity, $action, $payload),
                };

                $results[] = array_merge([
                    'op_id' => $opId,
                    'entity' => $entity,
                    'status' => 'synced',
                ], $result);
            } catch (SyncConflict $conflict) {
                $results[] = [
                    'op_id' => $opId,
                    'status' => 'conflict',
                    'message' => $conflict->getMessage(),
                    'record' => $conflict->record,
                ];
                break;
            } catch (ValidationException $exception) {
                $results[] = [
                    'op_id' => $opId,
                    'status' => 'error',
                    'message' => collect($exception->errors())->flatten()->first(),
                    'errors' => $exception->errors(),
                ];
                break;
            } catch (QueryException $exception) {
                report($exception);
                $results[] = [
                    'op_id' => $opId,
                    'status' => 'error',
                    'message' => str_contains($exception->getMessage(), 'Out of range')
                        ? 'An amount is too large. Edit the record and enter a smaller number.'
                        : 'This record could not be saved on the server.',
                ];
                break;
            }
        }

        return ['results' => $results];
    }

    public function pull(User $user, ?string $since, string $deviceId): array
    {
        $sinceAt = $since ? Carbon::parse($since)->subSeconds(2) : null;
        $companyId = $user->company_id;
        $serverTime = now()->toJSON();

        SyncCursor::query()->updateOrCreate(
            ['user_id' => $user->id, 'device_id' => $deviceId],
            ['company_id' => $companyId, 'cursor' => $serverTime],
        );

        $changed = function ($query) use ($sinceAt) {
            return $query->when($sinceAt, fn ($inner) => $inner->where('updated_at', '>=', $sinceAt));
        };

        return [
            'server_time' => $serverTime,
            'branches' => $changed(Branch::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'locations' => $changed(Location::query()->with('branch')->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'units' => $changed(Unit::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'categories' => $changed(Category::query()->with('parent')->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'brands' => $changed(Brand::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'products' => $changed(Product::query()->with(['unit', 'category', 'brand'])->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'adjustments' => $changed(StockAdjustment::query()->with('lines.product')->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'transfers' => $changed(StockTransfer::query()->with('lines.product')->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'write_offs' => $changed(StockWriteOff::query()->with('lines.product')->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'location_moves' => $changed(LocationMove::query()->with('lines.product')->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'events' => $changed(InventoryEvent::query()->with(['product', 'branch', 'operator', 'location', 'fromLocation', 'toLocation'])->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'balances' => BranchStock::query()->where('company_id', $companyId)->orderBy('id')->get()->map->toSyncArray()->values(),
            'layers' => StockLayer::query()->where('company_id', $companyId)->orderBy('id')->get()->map->toSyncArray()->values(),
            'location_stocks' => LocationStock::query()->where('company_id', $companyId)->orderBy('id')->get()->map->toSyncArray()->values(),
            'cheques' => $changed(Cheque::query()->with('branch')->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'partners' => $changed(InvestmentPartner::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'investments' => $changed(InvestmentEntry::query()->with('partner')->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'journals' => $changed(JournalEntry::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'day_closes' => $changed(DayClose::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'ledger_accounts' => tap($changed(LedgerAccount::query()->where('company_id', $companyId)), function () use ($companyId) {
                $this->bootstrap->seedChartIfMissing($companyId);
            })->orderBy('code')->get()->map->toSyncArray()->values(),
            'bank_accounts' => $changed(BankAccount::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'suppliers' => $changed(Supplier::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'purchases' => $changed(Purchase::query()->with(['lines.product', 'branch'])->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'purchase_returns' => $changed(PurchaseReturn::query()->with(['lines.product', 'branch'])->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'purchase_orders' => $changed(PurchaseOrder::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'purchase_payments' => $changed(PurchasePayment::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'parties' => $changed(Party::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'areas' => $changed(Area::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'credit_recoveries' => $changed(CreditRecovery::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'manufacturing_products' => $changed(ManufacturingProduct::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'sales' => $changed(Sale::query()->with(['lines.product', 'branch'])->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'expenses' => $changed(Expense::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'employees' => $changed(Employee::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'attendance_marks' => $changed(AttendanceMark::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'salary_payments' => $changed(SalaryPayment::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
            'shop_settings' => $changed(ShopDocument::query()->where('company_id', $companyId)->where('entity', 'shop_settings'))->orderBy('id')->get()->map->toSyncArray()->values(),
            'payment_methods' => $changed(ShopDocument::query()->where('company_id', $companyId)->where('entity', 'payment_method'))->orderBy('id')->get()->map->toSyncArray()->values(),
            'estimates' => $changed(ShopDocument::query()->where('company_id', $companyId)->where('entity', 'estimate'))->orderBy('id')->get()->map->toSyncArray()->values(),
            'sale_orders' => $changed(ShopDocument::query()->where('company_id', $companyId)->where('entity', 'sale_order'))->orderBy('id')->get()->map->toSyncArray()->values(),
            'delivery_notes' => $changed(ShopDocument::query()->where('company_id', $companyId)->where('entity', 'delivery_note'))->orderBy('id')->get()->map->toSyncArray()->values(),
            'tombstones' => $changed(SyncTombstone::query()->where('company_id', $companyId))->orderBy('id')->get()->map->toSyncArray()->values(),
        ];
    }
}
