<?php

namespace App\Services;

use App\Models\Area;
use App\Models\AttendanceMark;
use App\Models\BankAccount;
use App\Models\CreditRecovery;
use App\Models\Employee;
use App\Models\Expense;
use App\Models\LedgerAccount;
use App\Models\ManufacturingProduct;
use App\Models\Party;
use App\Models\SalaryPayment;
use App\Models\ShopDocument;
use App\Models\PurchaseOrder;
use App\Models\PurchasePayment;
use App\Models\Supplier;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class TradeService
{
    public function apply(User $user, string $entity, string $action, array $payload): array
    {
        $record = match ($entity) {
            'ledger_account' => $this->account($user, $payload),
            'bank_account' => $this->bank($user, $payload),
            'supplier' => $this->supplier($user, $payload),
            'purchase_order' => $this->order($user, $payload),
            'purchase_payment' => $this->payment($user, $payload),
            'party' => $this->party($user, $payload),
            'area' => $this->area($user, $payload),
            'credit_recovery' => $this->recovery($user, $payload),
            'manufacturing_product' => $this->recipe($user, $payload),
            'expense' => $this->expense($user, $payload),
            'employee' => $this->employee($user, $payload),
            'attendance' => $this->attendance($user, $payload),
            'salary_payment' => $this->salary($user, $payload),
            'shop_settings', 'payment_method', 'estimate', 'sale_order', 'delivery_note' => $this->shopDocument($user, $entity, $payload),
            default => throw ValidationException::withMessages(['entity' => 'Unknown trade document.']),
        };

        return ['record' => $record];
    }

    private function account(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $row = LedgerAccount::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first()
                ?? new LedgerAccount(['company_id' => $user->company_id, 'client_uuid' => $uuid, 'is_system' => false]);

            $type = strtolower(trim((string) ($payload['type'] ?? $row->type ?? '')));
            if (! in_array($type, ['asset', 'liability', 'equity', 'income', 'expense'], true)) {
                throw ValidationException::withMessages(['type' => 'Choose an account type.']);
            }
            $code = trim((string) ($payload['code'] ?? $row->code ?? ''));
            if ($code === '') {
                throw ValidationException::withMessages(['code' => 'Code is required.']);
            }
            $taken = LedgerAccount::query()
                ->where('company_id', $user->company_id)
                ->where('code', $code)
                ->where('client_uuid', '!=', $uuid)
                ->exists();
            if ($taken) {
                throw ValidationException::withMessages(['code' => 'That account code is already used.']);
            }

            $parent = trim((string) ($payload['parent_client_uuid'] ?? ''));
            if ($row->is_system) {
                $row->fill([
                    'name_en' => $this->required($payload, 'name_en', 'Name'),
                    'name_ur' => $this->nullable($payload, 'name_ur'),
                    'opening_balance' => $this->nonNegative($payload, 'opening_balance'),
                    'description' => $this->nullable($payload, 'description'),
                    'is_active' => $this->flag($payload, 'is_active', true),
                ]);
            } else {
                $row->fill([
                    'code' => $code,
                    'name_en' => $this->required($payload, 'name_en', 'Name'),
                    'name_ur' => $this->nullable($payload, 'name_ur'),
                    'type' => $type,
                    'parent_client_uuid' => $parent === '' ? null : $parent,
                    'opening_balance' => $this->nonNegative($payload, 'opening_balance'),
                    'description' => $this->nullable($payload, 'description'),
                    'is_active' => $this->flag($payload, 'is_active', true),
                    'is_system' => false,
                ]);
            }
            $row->save();

            return $row->toSyncArray();
        });
    }

    private function bank(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $row = BankAccount::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first()
                ?? new BankAccount(['company_id' => $user->company_id, 'client_uuid' => $uuid]);
            $row->fill([
                'name' => $this->required($payload, 'name', 'Bank name'),
                'account_title' => $this->nullable($payload, 'account_title'),
                'account_number' => $this->nullable($payload, 'account_number'),
                'opening_balance' => $this->nonNegative($payload, 'opening_balance'),
                'is_active' => $this->flag($payload, 'is_active', true),
            ]);
            $row->save();

            return $row->toSyncArray();
        });
    }

    private function supplier(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $row = Supplier::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first()
                ?? new Supplier(['company_id' => $user->company_id, 'client_uuid' => $uuid]);
            $row->fill([
                'name' => $this->required($payload, 'name', 'Supplier name'),
                'phone' => $this->nullable($payload, 'phone'),
                'address' => $this->nullable($payload, 'address'),
            ]);
            $row->save();

            return $row->toSyncArray();
        });
    }

    private function order(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $existing = PurchaseOrder::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first();
            if ($existing) {
                return $existing->toSyncArray();
            }
            $lines = $payload['lines'] ?? [];
            if (! is_array($lines) || count($lines) === 0) {
                throw ValidationException::withMessages(['lines' => 'Add at least one product line.']);
            }
            $row = PurchaseOrder::create([
                'company_id' => $user->company_id,
                'client_uuid' => $uuid,
                'supplier_name' => $this->required($payload, 'supplier_name', 'Supplier'),
                'occurred_on' => $this->date($payload, 'occurred_on'),
                'note' => $this->nullable($payload, 'note'),
                'status' => 'open',
                'lines' => array_values($lines),
            ]);

            return $row->toSyncArray();
        });
    }

    private function payment(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $existing = PurchasePayment::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first();
            if ($existing) {
                return $existing->toSyncArray();
            }
            $purchaseUuid = trim((string) ($payload['purchase_client_uuid'] ?? ''));
            if (! Str::isUuid($purchaseUuid)) {
                throw ValidationException::withMessages(['purchase' => 'Choose a purchase.']);
            }
            $amount = $payload['amount'] ?? null;
            if (! is_numeric($amount) || (float) $amount <= 0) {
                throw ValidationException::withMessages(['amount' => 'Enter an amount greater than zero.']);
            }
            $method = $payload['method'] ?? 'cash';
            if (! in_array($method, ['cash', 'bank'], true)) {
                $method = 'cash';
            }
            $row = PurchasePayment::create([
                'company_id' => $user->company_id,
                'client_uuid' => $uuid,
                'purchase_client_uuid' => $purchaseUuid,
                'amount' => number_format((float) $amount, 2, '.', ''),
                'method' => $method,
                'occurred_on' => $this->date($payload, 'occurred_on'),
                'note' => $this->nullable($payload, 'note'),
            ]);

            return $row->toSyncArray();
        });
    }

    private function party(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $type = ($payload['type'] ?? 'customer') === 'supplier' ? 'supplier' : 'customer';
            $side = ($payload['balance_side'] ?? 'they_owe') === 'we_owe' ? 'we_owe' : 'they_owe';
            $row = Party::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first()
                ?? new Party(['company_id' => $user->company_id, 'client_uuid' => $uuid]);
            $area = trim((string) ($payload['area_client_uuid'] ?? ''));
            $row->fill([
                'type' => $type,
                'name' => $this->required($payload, 'name', 'Name'),
                'name_ur' => $this->nullable($payload, 'name_ur'),
                'phone' => $this->nullable($payload, 'phone'),
                'route_day' => $this->nullable($payload, 'route_day'),
                'area_client_uuid' => $area === '' ? null : $area,
                'email' => $this->nullable($payload, 'email'),
                'cnic' => $this->nullable($payload, 'cnic'),
                'ntn' => $this->nullable($payload, 'ntn'),
                'strn' => $this->nullable($payload, 'strn'),
                'opening_balance' => $this->nonNegative($payload, 'opening_balance'),
                'balance_side' => $side,
                'price_mode' => in_array($payload['price_mode'] ?? 'ask', ['ask', 'retail', 'wholesale'], true) ? ($payload['price_mode'] ?? 'ask') : 'ask',
                'address' => $this->nullable($payload, 'address'),
            ]);
            $row->save();

            return $row->toSyncArray();
        });
    }

    private function area(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $row = Area::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first()
                ?? new Area(['company_id' => $user->company_id, 'client_uuid' => $uuid]);
            $row->fill(['name' => $this->required($payload, 'name', 'Area name')]);
            $row->save();

            return $row->toSyncArray();
        });
    }

    private function recovery(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $existing = CreditRecovery::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first();
            if ($existing) {
                return $existing->toSyncArray();
            }
            $party = trim((string) ($payload['party_client_uuid'] ?? ''));
            if (! Str::isUuid($party)) {
                throw ValidationException::withMessages(['party' => 'Choose a customer or supplier.']);
            }
            $amount = $payload['amount'] ?? null;
            if (! is_numeric($amount) || (float) $amount <= 0) {
                throw ValidationException::withMessages(['amount' => 'Enter an amount greater than zero.']);
            }
            $row = CreditRecovery::create([
                'company_id' => $user->company_id,
                'client_uuid' => $uuid,
                'party_client_uuid' => $party,
                'occurred_on' => $this->date($payload, 'occurred_on'),
                'amount' => number_format((float) $amount, 2, '.', ''),
                'method' => in_array($payload['method'] ?? 'cash', ['cash', 'bank'], true) ? ($payload['method'] ?? 'cash') : 'cash',
                'note' => $this->nullable($payload, 'note'),
            ]);

            return $row->toSyncArray();
        });
    }

    private function recipe(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $materials = $payload['materials'] ?? [];
            if (! is_array($materials) || count($materials) === 0) {
                throw ValidationException::withMessages(['materials' => 'Add at least one raw material.']);
            }
            $row = ManufacturingProduct::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first()
                ?? new ManufacturingProduct(['company_id' => $user->company_id, 'client_uuid' => $uuid]);
            $unit = trim((string) ($payload['unit_client_uuid'] ?? ''));
            $row->fill([
                'code' => $this->nullable($payload, 'code'),
                'barcode' => $this->nullable($payload, 'barcode'),
                'name' => $this->required($payload, 'name', 'Product name'),
                'unit_client_uuid' => $unit === '' ? null : $unit,
                'qty' => $this->nonNegative($payload, 'qty') === '0.00' ? '1.00' : $this->nonNegative($payload, 'qty'),
                'sale_price' => $this->nonNegative($payload, 'sale_price'),
                'wholesale_price' => $this->nonNegative($payload, 'wholesale_price'),
                'description' => $this->nullable($payload, 'description'),
                'packaging' => is_array($payload['packaging'] ?? null) ? $payload['packaging'] : [],
                'materials' => array_values($materials),
            ]);
            $row->save();

            return $row->toSyncArray();
        });
    }

    private function expense(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $row = Expense::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first()
                ?? new Expense(['company_id' => $user->company_id, 'client_uuid' => $uuid]);
            $account = trim((string) ($payload['account_client_uuid'] ?? ''));
            $row->fill([
                'occurred_on' => $this->date($payload, 'occurred_on'),
                'invoice_no' => $this->nullable($payload, 'invoice_no'),
                'account_client_uuid' => $account === '' ? null : $account,
                'account_name' => $this->required($payload, 'account_name', 'Expense account'),
                'narration' => $this->nullable($payload, 'narration'),
                'amount' => $this->nonNegative($payload, 'amount'),
                'method' => in_array($payload['method'] ?? 'cash', ['cash', 'bank'], true) ? ($payload['method'] ?? 'cash') : 'cash',
            ]);
            $row->save();

            return $row->toSyncArray();
        });
    }

    private function employee(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $row = Employee::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first()
                ?? new Employee(['company_id' => $user->company_id, 'client_uuid' => $uuid]);
            $type = in_array($payload['employment_type'] ?? 'full_time', ['full_time', 'part_time'], true) ? ($payload['employment_type'] ?? 'full_time') : 'full_time';
            $commission = in_array($payload['commission_on'] ?? 'none', ['none', 'sales', 'profit'], true) ? ($payload['commission_on'] ?? 'none') : 'none';
            $status = in_array($payload['status'] ?? 'active', ['active', 'inactive'], true) ? ($payload['status'] ?? 'active') : 'active';
            $joined = trim((string) ($payload['joined_on'] ?? ''));
            $row->fill([
                'name' => $this->required($payload, 'name', 'Name'),
                'name_ur' => $this->nullable($payload, 'name_ur'),
                'phone' => $this->nullable($payload, 'phone'),
                'cnic' => $this->nullable($payload, 'cnic'),
                'designation' => $this->nullable($payload, 'designation'),
                'employment_type' => $type,
                'monthly_salary' => $this->nonNegative($payload, 'monthly_salary'),
                'joined_on' => $joined === '' ? null : Carbon::parse($joined)->toDateString(),
                'commission_rate' => $this->nonNegative($payload, 'commission_rate'),
                'commission_on' => $commission,
                'status' => $status,
                'notes' => $this->nullable($payload, 'notes'),
                'allow_login' => $this->flag($payload, 'allow_login', false),
                'email' => $this->nullable($payload, 'email'),
            ]);
            $row->save();

            return $row->toSyncArray();
        });
    }

    private function attendance(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $employee = trim((string) ($payload['employee_client_uuid'] ?? ''));
            if (! Str::isUuid($employee)) {
                throw ValidationException::withMessages(['employee_client_uuid' => 'Choose an employee.']);
            }
            $status = in_array($payload['status'] ?? 'present', ['present', 'absent', 'leave', 'half'], true) ? ($payload['status'] ?? 'present') : 'present';
            $row = AttendanceMark::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first()
                ?? new AttendanceMark(['company_id' => $user->company_id, 'client_uuid' => $uuid]);
            $row->fill([
                'employee_client_uuid' => $employee,
                'work_date' => $this->date($payload, 'work_date'),
                'status' => $status,
                'check_in' => $this->nullable($payload, 'check_in'),
                'check_out' => $this->nullable($payload, 'check_out'),
                'note' => $this->nullable($payload, 'note'),
            ]);
            $row->save();

            return $row->toSyncArray();
        });
    }

    private function salary(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $existing = SalaryPayment::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first();
            if ($existing) {
                return $existing->toSyncArray();
            }
            $employee = trim((string) ($payload['employee_client_uuid'] ?? ''));
            if (! Str::isUuid($employee)) {
                throw ValidationException::withMessages(['employee_client_uuid' => 'Choose an employee.']);
            }
            $kind = in_array($payload['kind'] ?? 'salary', ['salary', 'advance', 'part'], true) ? ($payload['kind'] ?? 'salary') : 'salary';
            $row = SalaryPayment::query()->create([
                'company_id' => $user->company_id,
                'client_uuid' => $uuid,
                'employee_client_uuid' => $employee,
                'period' => $this->required($payload, 'period', 'Period'),
                'kind' => $kind,
                'amount' => $this->nonNegative($payload, 'amount'),
                'method' => in_array($payload['method'] ?? 'cash', ['cash', 'bank'], true) ? ($payload['method'] ?? 'cash') : 'cash',
                'paid_on' => $this->date($payload, 'paid_on'),
                'note' => $this->nullable($payload, 'note'),
            ]);

            return $row->toSyncArray();
        });
    }

    private function shopDocument(User $user, string $entity, array $payload): array
    {
        return DB::transaction(function () use ($user, $entity, $payload) {
            $uuid = $this->uuid($payload);
            $query = ShopDocument::query()->where('company_id', $user->company_id)->where('entity', $entity);
            $row = $entity === 'shop_settings'
                ? ($query->first() ?? new ShopDocument(['company_id' => $user->company_id, 'entity' => $entity, 'client_uuid' => $uuid]))
                : ($query->where('client_uuid', $uuid)->first() ?? new ShopDocument(['company_id' => $user->company_id, 'entity' => $entity, 'client_uuid' => $uuid]));
            $row->payload = $payload;
            $row->save();
            if ($entity === 'shop_settings') {
                $symbol = mb_substr(trim((string) ($payload['currency_symbol'] ?? '')), 0, 8);
                $code = mb_substr(trim((string) ($payload['currency_code'] ?? '')), 0, 8);
                if ($symbol !== '') {
                    $fields = ['currency_symbol' => $symbol];
                    if ($code !== '') {
                        $fields['currency_code'] = $code;
                    }
                    $user->company()->update($fields);
                }
            }

            return $row->toSyncArray();
        });
    }

    private function uuid(array $payload): string
    {
        $uuid = trim((string) ($payload['client_uuid'] ?? ''));
        if (! Str::isUuid($uuid)) {
            throw ValidationException::withMessages(['client_uuid' => 'A client UUID is required.']);
        }

        return $uuid;
    }

    private function required(array $payload, string $key, string $label): string
    {
        $value = trim((string) ($payload[$key] ?? ''));
        if ($value === '') {
            throw ValidationException::withMessages([$key => $label.' is required.']);
        }

        return $value;
    }

    private function nullable(array $payload, string $key): ?string
    {
        $value = trim((string) ($payload[$key] ?? ''));

        return $value === '' ? null : $value;
    }

    private function nonNegative(array $payload, string $key): string
    {
        $value = $payload[$key] ?? 0;
        if (! is_numeric($value) || (float) $value < 0) {
            throw ValidationException::withMessages([$key => 'Amount cannot be negative.']);
        }

        return number_format((float) $value, 2, '.', '');
    }

    private function flag(array $payload, string $key, bool $default): bool
    {
        if (! array_key_exists($key, $payload)) {
            return $default;
        }

        return filter_var($payload[$key], FILTER_VALIDATE_BOOLEAN);
    }

    private function date(array $payload, string $key): string
    {
        $value = trim((string) ($payload[$key] ?? ''));
        if ($value === '') {
            return now()->toDateString();
        }

        return Carbon::parse($value)->toDateString();
    }
}
