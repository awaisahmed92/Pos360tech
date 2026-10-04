<?php

namespace Tests\Feature;

use App\Services\MasterClientRegistry;
use App\Models\BranchStock;
use App\Models\Company;
use App\Models\InventoryEvent;
use App\Models\LocationStock;
use App\Models\StockAdjustment;
use App\Models\Unit;
use Illuminate\Support\Facades\DB;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class PosFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_creates_company_branch_godown_and_units(): void
    {
        $response = $this->postJson('/api/auth/register', $this->ownerPayload());

        $response->assertCreated()
            ->assertJsonPath('user.role', 'owner')
            ->assertJsonPath('company.currency_code', 'PKR')
            ->assertJsonPath('branches.0.name', 'Main Branch')
            ->assertJsonPath('locations.0.name', 'Main Godown')
            ->assertJsonPath('locations.0.is_default', true);

        $this->assertGreaterThanOrEqual(8, Unit::query()->count());
        $this->assertDatabaseHas('device_sessions', ['device_id' => 'device-1']);
        $this->assertDatabaseHas('companies', ['company_code' => 'demoshop']);
        $master = DB::connection('master')->table('tenants')->where('company_code', 'demoshop')->first();
        $this->assertNotNull($master);
        $this->assertSame(1, (int) $master->pos_app);
        $this->assertSame(0, (int) $master->hr_app);
    }

    public function test_signup_reuses_the_shared_master_client(): void
    {
        app(MasterClientRegistry::class)->ensureSchema();
        DB::connection('master')->table('tenants')->insert([
            'name' => 'Ali Traders',
            'subdomain' => 'alitraders',
            'company_code' => 'alitraders',
            'db_host' => '127.0.0.1',
            'db_name' => 'hr360_alitraders',
            'db_user' => 'root',
            'db_password' => '',
            'status' => 'active',
            'hr_app' => 1,
            'accounts_app' => 0,
            'pos_app' => 0,
            'source' => 'signup',
            'created_at' => now(),
        ]);
        $existingId = (int) DB::connection('master')->table('tenants')->where('subdomain', 'alitraders')->value('id');

        $this->postJson('/api/signup', [
            'name' => 'Ali Khan',
            'company_name' => 'Ali Traders',
            'company_code' => 'Ali Traders',
            'designation' => 'Owner',
            'industry' => 'Retail',
            'country' => 'Pakistan',
            'email' => 'ali@traders.test',
            'phone' => '03001234567',
            'password' => 'secret1',
        ])->assertCreated()
            ->assertJsonPath('organization', 'alitraders')
            ->assertJsonPath('user_name', 'Ali Khan');

        $this->assertSame(1, DB::connection('master')->table('tenants')->count());
        $row = DB::connection('master')->table('tenants')->where('id', $existingId)->first();
        $this->assertSame(1, (int) $row->pos_app);
        $this->assertSame(1, (int) $row->hr_app);
        $this->assertSame('hr360_alitraders', $row->db_name);
        $this->assertSame($existingId, (int) Company::query()->where('company_code', 'alitraders')->value('master_tenant_id'));

        $this->postJson('/api/auth/login', [
            'company_code' => 'alitraders',
            'username' => 'Ali Khan',
            'password' => 'secret1',
            'device_id' => 'till-9',
        ])->assertOk()->assertJsonPath('user.username', 'Ali Khan');

        $this->postJson('/api/signup', [
            'name' => 'Other',
            'company_name' => 'Ali Traders',
            'company_code' => 'alitraders',
            'designation' => 'Manager',
            'industry' => 'Retail',
            'country' => 'Pakistan',
            'email' => 'other@traders.test',
            'password' => 'secret1',
        ])->assertStatus(422);
    }

    public function test_stock_documents_follow_fifo_and_allow_negative_stock(): void
    {
        [$token, $main, $unit] = $this->bootShop();
        $second = $this->withToken($token)->postJson('/api/branches', [
            'client_uuid' => (string) Str::uuid(),
            'name' => 'Warehouse',
            'code' => 'WH',
        ])->assertCreated()->json('record.id');

        $product = $this->withToken($token)->postJson('/api/products', [
            'client_uuid' => (string) Str::uuid(),
            'name_en' => 'Sugar',
            'unit_id' => $unit,
            'purchase_price' => 4,
            'sale_price' => 10,
            'alert_qty' => 2,
        ])->assertCreated()->json('record.id');

        $this->postStock($token, '/api/stock/adjustments', [
            'client_uuid' => (string) Str::uuid(),
            'branch_id' => $main,
            'kind' => 'opening',
            'reason' => 'Opening count',
            'lines' => [['product_id' => $product, 'qty' => 10, 'unit_cost' => 5]],
        ])->assertCreated();

        $this->postStock($token, '/api/stock/transfers', [
            'client_uuid' => (string) Str::uuid(),
            'from_branch_id' => $main,
            'to_branch_id' => $second,
            'lines' => [['product_id' => $product, 'qty' => 4]],
        ])->assertCreated();

        $this->postStock($token, '/api/stock/adjustments', [
            'client_uuid' => (string) Str::uuid(),
            'branch_id' => $main,
            'kind' => 'increase',
            'lines' => [['product_id' => $product, 'qty' => 5, 'unit_cost' => 8]],
        ])->assertCreated();

        $this->postStock($token, '/api/stock/write-offs', [
            'client_uuid' => (string) Str::uuid(),
            'branch_id' => $main,
            'reason' => 'Damaged bag',
            'lines' => [['product_id' => $product, 'qty' => 8]],
        ])->assertCreated();

        $mainStock = BranchStock::query()->where('branch_id', $main)->where('product_id', $product)->first();
        $this->assertSame('3.000', $mainStock->qty_on_hand);
        $this->assertSame('24.00', $mainStock->stock_value);

        $writeOff = InventoryEvent::query()->where('event_type', 'write_off')->first();
        $this->assertSame('-8.000', $writeOff->qty);
        $this->assertSame('-46.00', $writeOff->value);
        $this->assertSame('3.000', $writeOff->running_balance);

        $this->postStock($token, '/api/stock/write-offs', [
            'client_uuid' => (string) Str::uuid(),
            'branch_id' => $main,
            'reason' => 'Count short',
            'lines' => [['product_id' => $product, 'qty' => 10]],
        ])->assertCreated();

        $mainStock->refresh();
        $this->assertSame('-7.000', $mainStock->qty_on_hand);

        $summary = $this->withToken($token)->getJson('/api/stock/summary?branch_id='.$main)->assertOk()->json('data');
        $this->assertSame(1, $summary['out_of_stock']);
        $this->assertNotSame('0.00', $summary['wastage_this_month']);
    }

    public function test_location_move_does_not_change_branch_quantity(): void
    {
        [$token, $main, $unit] = $this->bootShop();
        $product = $this->withToken($token)->postJson('/api/products', [
            'client_uuid' => (string) Str::uuid(),
            'name_en' => 'Rice',
            'unit_id' => $unit,
            'purchase_price' => 3,
        ])->json('record.id');

        $this->postStock($token, '/api/stock/adjustments', [
            'client_uuid' => (string) Str::uuid(),
            'branch_id' => $main,
            'kind' => 'opening',
            'lines' => [['product_id' => $product, 'qty' => 6, 'unit_cost' => 3]],
        ])->assertCreated();

        $shelf = $this->withToken($token)->postJson('/api/locations', [
            'client_uuid' => (string) Str::uuid(),
            'branch_id' => $main,
            'name' => 'Shelf',
        ])->assertCreated()->json('record.id');

        $default = $this->withToken($token)->getJson('/api/locations')->json('data.0.id');

        $this->postStock($token, '/api/stock/location-moves', [
            'client_uuid' => (string) Str::uuid(),
            'branch_id' => $main,
            'from_location_id' => $default,
            'to_location_id' => $shelf,
            'lines' => [['product_id' => $product, 'qty' => 2]],
        ])->assertCreated();

        $this->assertSame('6.000', BranchStock::query()->where('product_id', $product)->value('qty_on_hand'));
        $this->assertSame('4.000', LocationStock::query()->where('location_id', $default)->where('product_id', $product)->value('qty_on_hand'));
        $this->assertSame('2.000', LocationStock::query()->where('location_id', $shelf)->where('product_id', $product)->value('qty_on_hand'));

        $move = InventoryEvent::query()->where('event_type', 'location_move')->first();
        $this->assertSame('6.000', $move->running_balance);
        $this->assertSame('0.00', $move->value);
    }

    public function test_replay_is_idempotent_and_sync_pulls_the_ledger(): void
    {
        [$token, $main, $unit] = $this->bootShop();
        $productUuid = (string) Str::uuid();
        $adjustmentUuid = (string) Str::uuid();

        $push = [
            'device_id' => 'device-1',
            'operations' => [
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'product',
                    'action' => 'create',
                    'client_uuid' => $productUuid,
                    'payload' => [
                        'client_uuid' => $productUuid,
                        'name_en' => 'Tea',
                        'unit_id' => $unit,
                        'purchase_price' => 2,
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'stock_adjustment',
                    'action' => 'create',
                    'client_uuid' => $adjustmentUuid,
                    'payload' => [
                        'client_uuid' => $adjustmentUuid,
                        'branch_id' => $main,
                        'kind' => 'opening',
                        'lines' => [['product_client_uuid' => $productUuid, 'qty' => 3, 'unit_cost' => 2]],
                    ],
                ],
            ],
        ];

        $this->withToken($token)->postJson('/api/sync/push', $push)->assertOk()->assertJsonPath('results.1.status', 'synced');
        $this->withToken($token)->postJson('/api/sync/push', $push)->assertOk()->assertJsonPath('results.1.idempotent', true);
        $this->assertSame(1, StockAdjustment::query()->count());
        $this->assertSame(1, InventoryEvent::query()->where('event_type', 'opening')->count());

        $pull = $this->withToken($token)->getJson('/api/sync/pull?device_id=device-1')->assertOk();
        $pull->assertJsonFragment(['name_en' => 'Tea']);
        $this->assertNotEmpty($pull->json('events'));
        $this->assertDatabaseHas('sync_cursors', ['device_id' => 'device-1']);
    }

    public function test_cashier_can_read_stock_but_cannot_post_it(): void
    {
        [$token, $main, $unit] = $this->bootShop();
        $this->withToken($token)->postJson('/api/users', [
            'name' => 'Cashier',
            'email' => 'cashier@pos360.test',
            'password' => 'password123',
            'role' => 'cashier',
        ])->assertCreated();

        $login = $this->postJson('/api/auth/login', [
            'email' => 'cashier@pos360.test',
            'password' => 'password123',
            'device_id' => 'till-1',
        ])->assertOk();
        $login->assertJsonPath('user.role', 'cashier');
        $cashier = $login->json('token');

        $this->app['auth']->forgetGuards();
        $this->flushHeaders()->withToken($cashier)->postJson('/api/stock/adjustments', [
            'client_uuid' => (string) Str::uuid(),
            'branch_id' => $main,
            'kind' => 'opening',
            'lines' => [['product_id' => 1, 'qty' => 1, 'unit_cost' => 1]],
        ])->assertForbidden();

        $this->withToken($cashier)->getJson('/api/stock/events')->assertOk();
        $this->withToken($cashier)->getJson('/api/stock/summary')->assertOk();
    }

    public function test_ledger_exports_csv_and_pdf(): void
    {
        [$token, $main, $unit] = $this->bootShop();
        $product = $this->withToken($token)->postJson('/api/products', [
            'client_uuid' => (string) Str::uuid(),
            'name_en' => 'Milk',
            'unit_id' => $unit,
        ])->json('record.id');

        $this->postStock($token, '/api/stock/adjustments', [
            'client_uuid' => (string) Str::uuid(),
            'branch_id' => $main,
            'kind' => 'opening',
            'lines' => [['product_id' => $product, 'qty' => 1, 'unit_cost' => 9]],
        ]);

        $csv = $this->withToken($token)->get('/api/stock/events/export.csv');
        $csv->assertOk();
        $this->assertStringContainsString('Milk', $csv->streamedContent());

        $pdf = $this->withToken($token)->get('/api/stock/events/export.pdf');
        $pdf->assertOk();
        $this->assertStringContainsString('pdf', strtolower($pdf->headers->get('content-type')));
    }

    public function test_stale_catalog_push_conflicts(): void
    {
        [$token, $main, $unit] = $this->bootShop();
        $uuid = (string) Str::uuid();
        $created = $this->withToken($token)->postJson('/api/products', [
            'client_uuid' => $uuid,
            'name_en' => 'Soap',
            'unit_id' => $unit,
        ])->assertCreated();
        $base = $created->json('record.updated_at');

        $this->travel(2)->seconds();
        $this->withToken($token)->putJson('/api/products/'.$created->json('record.id'), [
            'name_en' => 'Soap Bar',
            'unit_id' => $unit,
            'base_updated_at' => $base,
        ])->assertOk();

        $result = $this->withToken($token)->postJson('/api/sync/push', [
            'device_id' => 'device-1',
            'operations' => [[
                'op_id' => (string) Str::uuid(),
                'entity' => 'product',
                'action' => 'update',
                'payload' => [
                    'client_uuid' => $uuid,
                    'name_en' => 'Old Soap',
                    'unit_id' => $unit,
                    'base_updated_at' => $base,
                ],
            ]],
        ])->assertOk();

        $result->assertJsonPath('results.0.status', 'conflict');
    }

    public function test_cheques_and_investment_sync(): void
    {
        [$token] = $this->bootShop();
        $partner = (string) Str::uuid();
        $cheque = (string) Str::uuid();
        $entry = (string) Str::uuid();

        $push = $this->withToken($token)->postJson('/api/sync/push', [
            'device_id' => 'device-1',
            'operations' => [
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'investment_partner',
                    'action' => 'create',
                    'client_uuid' => $partner,
                    'payload' => [
                        'client_uuid' => $partner,
                        'name' => 'Owner',
                        'is_owner' => true,
                        'profit_share' => 100,
                        'loss_share' => 100,
                        'shares_loss' => true,
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'investment_entry',
                    'action' => 'create',
                    'client_uuid' => $entry,
                    'payload' => [
                        'client_uuid' => $entry,
                        'partner_client_uuid' => $partner,
                        'kind' => 'in',
                        'method' => 'cash',
                        'amount' => 50000,
                        'occurred_on' => '2026-10-03',
                        'note' => 'Opening capital',
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'cheque',
                    'action' => 'create',
                    'client_uuid' => $cheque,
                    'payload' => [
                        'client_uuid' => $cheque,
                        'direction' => 'in',
                        'cheque_no' => 'CHQ-1001',
                        'bank' => 'HBL',
                        'party_name' => 'Ali Traders',
                        'amount' => 15000,
                        'issued_on' => '2026-10-03',
                        'status' => 'pending',
                    ],
                ],
            ],
        ])->assertOk();

        $push->assertJsonPath('results.0.status', 'synced');
        $push->assertJsonPath('results.1.status', 'synced');
        $push->assertJsonPath('results.2.status', 'synced');
        $this->assertDatabaseHas('cheques', ['cheque_no' => 'CHQ-1001', 'amount' => 15000]);
        $this->assertDatabaseHas('investment_entries', ['amount' => 50000]);

        $again = $this->withToken($token)->postJson('/api/sync/push', [
            'device_id' => 'device-1',
            'operations' => [[
                'op_id' => (string) Str::uuid(),
                'entity' => 'cheque',
                'action' => 'create',
                'payload' => [
                    'client_uuid' => $cheque,
                    'direction' => 'in',
                    'cheque_no' => 'CHQ-1001',
                    'amount' => 15000,
                    'issued_on' => '2026-10-03',
                ],
            ]],
        ])->assertOk();
        $again->assertJsonPath('results.0.status', 'synced');
        $this->assertSame(1, \App\Models\Cheque::query()->count());
    }

    public function test_journal_and_day_close_sync(): void
    {
        [$token] = $this->bootShop();
        $journal = (string) Str::uuid();
        $close = (string) Str::uuid();

        $push = $this->withToken($token)->postJson('/api/sync/push', [
            'device_id' => 'device-1',
            'operations' => [
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'journal_entry',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $journal,
                        'occurred_on' => '2026-10-03',
                        'narration' => 'Cash sale',
                        'method' => 'cash',
                        'debit' => 2500,
                        'credit' => 0,
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'day_close',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $close,
                        'closed_on' => '2026-10-03',
                        'opening_cash' => 1000,
                        'counted_cash' => 3500,
                        'note' => 'Drawer matched',
                    ],
                ],
            ],
        ])->assertOk();

        $push->assertJsonPath('results.0.status', 'synced');
        $push->assertJsonPath('results.1.status', 'synced');
        $this->assertDatabaseHas('journal_entries', ['narration' => 'Cash sale']);
        $this->assertDatabaseHas('day_closes', ['counted_cash' => 3500]);
    }

    public function test_chart_bank_and_purchase_sync(): void
    {
        [$token, $branchId] = $this->bootShop();
        $this->assertDatabaseCount('ledger_accounts', 14);

        $account = (string) Str::uuid();
        $bank = (string) Str::uuid();
        $supplier = (string) Str::uuid();
        $productUuid = (string) Str::uuid();
        $purchase = (string) Str::uuid();
        $branchUuid = \App\Models\Branch::query()->find($branchId)->client_uuid;
        $unit = Unit::query()->where('short_name', 'pc')->value('id');

        $this->withToken($token)->postJson('/api/products', [
            'client_uuid' => $productUuid,
            'name_en' => 'Rice',
            'unit_id' => $unit,
            'purchase_price' => 100,
            'sale_price' => 140,
        ])->assertCreated();

        $push = $this->withToken($token)->postJson('/api/sync/push', [
            'device_id' => 'device-1',
            'operations' => [
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'ledger_account',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $account,
                        'code' => '5300',
                        'name_en' => 'Utilities',
                        'name_ur' => 'یوٹیلٹی',
                        'type' => 'expense',
                        'opening_balance' => 0,
                        'is_active' => true,
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'bank_account',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $bank,
                        'name' => 'Bank Al Habib',
                        'account_title' => 'Shop account',
                        'account_number' => '123',
                        'opening_balance' => 5000,
                        'is_active' => true,
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'supplier',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $supplier,
                        'name' => 'Ali Traders',
                        'phone' => '03001234567',
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'purchase',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $purchase,
                        'branch_client_uuid' => $branchUuid,
                        'supplier_client_uuid' => $supplier,
                        'supplier_name' => 'Ali Traders',
                        'invoice_no' => 'P-1',
                        'occurred_at' => '2026-10-03T10:00:00Z',
                        'payment_method' => 'cash',
                        'update_cost' => true,
                        'lines' => [[
                            'product_client_uuid' => $productUuid,
                            'qty' => 4,
                            'unit_cost' => 90,
                            'tax_percent' => 0,
                        ]],
                    ],
                ],
            ],
        ])->assertOk();

        $push->assertJsonPath('results.0.status', 'synced');
        $push->assertJsonPath('results.3.status', 'synced');
        $this->assertDatabaseHas('ledger_accounts', ['code' => '5300', 'name_en' => 'Utilities']);
        $this->assertDatabaseHas('bank_accounts', ['name' => 'Bank Al Habib']);
        $this->assertDatabaseHas('suppliers', ['name' => 'Ali Traders']);
        $this->assertDatabaseHas('purchases', ['invoice_no' => 'P-1', 'total' => 360]);
        $productId = \App\Models\Product::query()->where('client_uuid', $productUuid)->value('id');
        $stock = BranchStock::query()->where('branch_id', $branchId)->where('product_id', $productId)->first();
        $this->assertNotNull($stock);
        $this->assertSame('4.000', (string) $stock->qty_on_hand);
        $this->assertSame('90.00', (string) \App\Models\Product::query()->where('client_uuid', $productUuid)->value('purchase_price'));
    }

    public function test_party_area_and_recovery_sync(): void
    {
        [$token] = $this->bootShop();
        $area = (string) Str::uuid();
        $party = (string) Str::uuid();
        $recovery = (string) Str::uuid();

        $push = $this->withToken($token)->postJson('/api/sync/push', [
            'device_id' => 'device-1',
            'operations' => [
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'area',
                    'action' => 'create',
                    'payload' => ['client_uuid' => $area, 'name' => 'Rehman Bagh'],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'party',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $party,
                        'type' => 'customer',
                        'name' => 'Ahmed',
                        'phone' => '03001112222',
                        'area_client_uuid' => $area,
                        'opening_balance' => 1500,
                        'balance_side' => 'they_owe',
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'credit_recovery',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $recovery,
                        'party_client_uuid' => $party,
                        'occurred_on' => '2026-10-03',
                        'amount' => 500,
                        'method' => 'cash',
                        'note' => 'Partial',
                    ],
                ],
            ],
        ])->assertOk();

        $push->assertJsonPath('results.0.status', 'synced');
        $push->assertJsonPath('results.2.status', 'synced');
        $this->assertDatabaseHas('areas', ['name' => 'Rehman Bagh']);
        $this->assertDatabaseHas('parties', ['name' => 'Ahmed', 'opening_balance' => 1500]);
        $this->assertDatabaseHas('credit_recoveries', ['amount' => 500]);
    }

    public function test_sale_expense_and_payroll_sync(): void
    {
        [$token, $branchId] = $this->bootShop();
        $productUuid = (string) Str::uuid();
        $branchUuid = \App\Models\Branch::query()->find($branchId)->client_uuid;
        $unit = Unit::query()->where('short_name', 'pc')->value('id');
        $this->withToken($token)->postJson('/api/products', [
            'client_uuid' => $productUuid,
            'name_en' => 'Soap',
            'unit_id' => $unit,
            'purchase_price' => 40,
            'sale_price' => 60,
        ])->assertCreated();

        $purchase = (string) Str::uuid();
        $sale = (string) Str::uuid();
        $expense = (string) Str::uuid();
        $employee = (string) Str::uuid();
        $attendance = (string) Str::uuid();
        $salary = (string) Str::uuid();

        $push = $this->withToken($token)->postJson('/api/sync/push', [
            'device_id' => 'device-1',
            'operations' => [
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'purchase',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $purchase,
                        'branch_client_uuid' => $branchUuid,
                        'invoice_no' => 'P-SOAP',
                        'occurred_at' => '2026-10-03T09:00:00Z',
                        'payment_method' => 'cash',
                        'lines' => [[
                            'product_client_uuid' => $productUuid,
                            'qty' => 5,
                            'unit_cost' => 40,
                        ]],
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'sale',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $sale,
                        'branch_client_uuid' => $branchUuid,
                        'party_name' => 'Walk in',
                        'invoice_no' => 'S-1',
                        'occurred_at' => '2026-10-03T11:00:00Z',
                        'payment_method' => 'cash',
                        'lines' => [[
                            'product_client_uuid' => $productUuid,
                            'qty' => 2,
                            'unit_price' => 60,
                        ]],
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'expense',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $expense,
                        'occurred_on' => '2026-10-03',
                        'invoice_no' => 'E-1',
                        'account_name' => 'Rent',
                        'narration' => 'October rent',
                        'amount' => 15000,
                        'method' => 'cash',
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'employee',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $employee,
                        'name' => 'Sana',
                        'designation' => 'Cashier',
                        'employment_type' => 'full_time',
                        'monthly_salary' => 25000,
                        'status' => 'active',
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'attendance',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $attendance,
                        'employee_client_uuid' => $employee,
                        'work_date' => '2026-10-03',
                        'status' => 'present',
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'salary_payment',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $salary,
                        'employee_client_uuid' => $employee,
                        'period' => '2026-10',
                        'kind' => 'advance',
                        'amount' => 5000,
                        'method' => 'cash',
                        'paid_on' => '2026-10-03',
                    ],
                ],
            ],
        ])->assertOk();

        $push->assertJsonPath('results.1.status', 'synced');
        $push->assertJsonPath('results.1.document.total', '120.00');
        $push->assertJsonPath('results.2.status', 'synced');
        $push->assertJsonPath('results.5.status', 'synced');
        $productId = \App\Models\Product::query()->where('client_uuid', $productUuid)->value('id');
        $this->assertSame('3.000', (string) BranchStock::query()->where('branch_id', $branchId)->where('product_id', $productId)->value('qty_on_hand'));
        $this->assertDatabaseHas('expenses', ['invoice_no' => 'E-1', 'amount' => 15000]);
        $this->assertDatabaseHas('employees', ['name' => 'Sana']);
        $this->assertDatabaseHas('attendance_marks', ['status' => 'present']);
        $this->assertDatabaseHas('salary_payments', ['amount' => 5000, 'kind' => 'advance']);
    }

    public function test_shop_settings_and_payment_method_sync(): void
    {
        [$token] = $this->bootShop();
        $settings = '10000000-0000-4000-8000-000000009001';
        $method = '10000000-0000-4000-8000-000000000101';

        $push = $this->withToken($token)->postJson('/api/sync/push', [
            'device_id' => 'device-1',
            'operations' => [
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'shop_settings',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $settings,
                        'shop_name' => 'Demo Shop',
                        'invoice_prefix' => 'INV-',
                        'timezone' => 'Asia/Karachi',
                    ],
                ],
                [
                    'op_id' => (string) Str::uuid(),
                    'entity' => 'payment_method',
                    'action' => 'create',
                    'payload' => [
                        'client_uuid' => $method,
                        'name' => 'Cash',
                        'goes_to' => 'cash',
                        'is_active' => true,
                    ],
                ],
            ],
        ])->assertOk();

        $push->assertJsonPath('results.0.status', 'synced');
        $push->assertJsonPath('results.1.status', 'synced');
        $this->assertDatabaseHas('shop_documents', ['entity' => 'shop_settings', 'client_uuid' => $settings]);
        $this->assertDatabaseHas('shop_documents', ['entity' => 'payment_method', 'client_uuid' => $method]);

        $pull = $this->withToken($token)->getJson('/api/sync/pull?device_id=device-1')->assertOk();
        $pull->assertJsonPath('shop_settings.0.shop_name', 'Demo Shop');
        $pull->assertJsonPath('payment_methods.0.name', 'Cash');
    }

    private function bootShop(): array
    {
        $response = $this->postJson('/api/auth/register', $this->ownerPayload())->assertCreated();

        return [
            $response->json('token'),
            $response->json('branches.0.id'),
            $response->json('units') ? null : Unit::query()->where('short_name', 'pc')->value('id'),
        ];
    }

    private function ownerPayload(): array
    {
        return [
            'company_name' => 'Demo Shop',
            'name' => 'Owner',
            'email' => 'owner@pos360.test',
            'password' => 'password123',
            'device_id' => 'device-1',
            'device_name' => 'phpunit',
        ];
    }

    private function postStock(string $token, string $url, array $payload)
    {
        return $this->withToken($token)->postJson($url, $payload);
    }
}
