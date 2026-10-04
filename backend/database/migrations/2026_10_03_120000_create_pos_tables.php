<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('companies', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('currency_code', 8)->default('PKR');
            $table->string('currency_symbol', 8)->default('Rs');
            $table->string('subscription_status', 32)->default('trial');
            $table->timestamp('trial_ends_at')->nullable();
            $table->timestamps();
        });

        Schema::table('users', function (Blueprint $table) {
            $table->unsignedBigInteger('company_id')->nullable()->index();
            $table->string('role', 20)->default('cashier');
            $table->string('phone')->nullable();
            $table->boolean('is_active')->default(true);
        });

        Schema::create('branches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('name');
            $table->string('code', 40)->nullable();
            $table->boolean('is_main')->default(false);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('locations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('name');
            $table->boolean('is_default')->default(false);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('device_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('device_id', 100);
            $table->string('device_name')->nullable();
            $table->timestamp('last_seen_at')->nullable();
            $table->timestamps();
            $table->unique(['user_id', 'device_id']);
        });

        Schema::create('sync_cursors', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('device_id', 100);
            $table->string('cursor', 64)->nullable();
            $table->timestamps();
            $table->unique(['user_id', 'device_id']);
        });

        Schema::create('sync_tombstones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->string('entity', 40);
            $table->unsignedBigInteger('record_id')->nullable();
            $table->uuid('client_uuid')->nullable();
            $table->timestamps();
            $table->index(['company_id', 'updated_at']);
        });

        Schema::create('units', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('name_en');
            $table->string('name_ur')->nullable();
            $table->string('short_name', 20);
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('categories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->foreignId('parent_id')->nullable()->constrained('categories')->nullOnDelete();
            $table->string('name_en');
            $table->string('name_ur')->nullable();
            $table->string('code', 40)->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('brands', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('name_en');
            $table->string('name_ur')->nullable();
            $table->string('code', 40)->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('code', 40);
            $table->string('barcode', 64)->nullable();
            $table->string('name_en');
            $table->string('name_ur')->nullable();
            $table->foreignId('category_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('brand_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('unit_id')->constrained();
            $table->decimal('purchase_price', 15, 2)->default(0);
            $table->decimal('sale_price', 15, 2)->default(0);
            $table->decimal('wholesale_price', 15, 2)->default(0);
            $table->decimal('alert_qty', 15, 3)->default(0);
            $table->boolean('track_stock')->default(true);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
            $table->unique(['company_id', 'code']);
            $table->unique(['company_id', 'barcode']);
        });

        Schema::create('branch_stock', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->decimal('qty_on_hand', 15, 3)->default(0);
            $table->decimal('stock_value', 15, 2)->default(0);
            $table->timestamps();
            $table->unique(['branch_id', 'product_id']);
        });

        Schema::create('location_stock', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('location_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->decimal('qty_on_hand', 15, 3)->default(0);
            $table->timestamps();
            $table->unique(['location_id', 'product_id']);
        });

        Schema::create('stock_layers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->decimal('qty_remaining', 15, 3);
            $table->decimal('unit_cost', 15, 4);
            $table->unsignedBigInteger('source_event_id')->nullable()->index();
            $table->timestamp('received_at');
            $table->timestamps();
            $table->index(['branch_id', 'product_id', 'received_at']);
        });

        Schema::create('inventory_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->foreignId('branch_id')->constrained();
            $table->foreignId('product_id')->constrained();
            $table->foreignId('location_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('from_location_id')->nullable()->constrained('locations')->nullOnDelete();
            $table->foreignId('to_location_id')->nullable()->constrained('locations')->nullOnDelete();
            $table->string('event_type', 40);
            $table->decimal('qty', 15, 3);
            $table->decimal('unit_cost', 15, 4)->default(0);
            $table->decimal('value', 15, 2)->default(0);
            $table->decimal('running_balance', 15, 3)->default(0);
            $table->string('source_type', 40)->nullable();
            $table->unsignedBigInteger('source_id')->nullable();
            $table->uuid('source_uuid')->nullable();
            $table->string('reason', 500)->nullable();
            $table->foreignId('operator_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('occurred_at');
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
            $table->index(['company_id', 'occurred_at']);
            $table->index(['company_id', 'source_uuid']);
            $table->index(['branch_id', 'product_id']);
        });

        Schema::create('stock_adjustments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->foreignId('branch_id')->constrained();
            $table->foreignId('location_id')->nullable()->constrained()->nullOnDelete();
            $table->string('kind', 20);
            $table->string('reason', 500)->nullable();
            $table->timestamp('occurred_at');
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('stock_adjustment_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('stock_adjustment_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained();
            $table->decimal('qty', 15, 3);
            $table->decimal('unit_cost', 15, 4)->default(0);
            $table->decimal('value', 15, 2)->default(0);
            $table->timestamps();
        });

        Schema::create('stock_transfers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->foreignId('from_branch_id')->constrained('branches');
            $table->foreignId('to_branch_id')->constrained('branches');
            $table->foreignId('from_location_id')->nullable()->constrained('locations')->nullOnDelete();
            $table->foreignId('to_location_id')->nullable()->constrained('locations')->nullOnDelete();
            $table->string('reason', 500)->nullable();
            $table->timestamp('occurred_at');
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('stock_transfer_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('stock_transfer_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained();
            $table->decimal('qty', 15, 3);
            $table->decimal('unit_cost', 15, 4)->default(0);
            $table->decimal('value', 15, 2)->default(0);
            $table->timestamps();
        });

        Schema::create('stock_write_offs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->foreignId('branch_id')->constrained();
            $table->foreignId('location_id')->nullable()->constrained()->nullOnDelete();
            $table->string('reason', 500)->nullable();
            $table->timestamp('occurred_at');
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('stock_write_off_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('stock_write_off_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained();
            $table->decimal('qty', 15, 3);
            $table->decimal('unit_cost', 15, 4)->default(0);
            $table->decimal('value', 15, 2)->default(0);
            $table->timestamps();
        });

        Schema::create('location_moves', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->foreignId('branch_id')->constrained();
            $table->foreignId('from_location_id')->constrained('locations');
            $table->foreignId('to_location_id')->constrained('locations');
            $table->string('reason', 500)->nullable();
            $table->timestamp('occurred_at');
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('location_move_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('location_move_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained();
            $table->decimal('qty', 15, 3);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('location_move_lines');
        Schema::dropIfExists('location_moves');
        Schema::dropIfExists('stock_write_off_lines');
        Schema::dropIfExists('stock_write_offs');
        Schema::dropIfExists('stock_transfer_lines');
        Schema::dropIfExists('stock_transfers');
        Schema::dropIfExists('stock_adjustment_lines');
        Schema::dropIfExists('stock_adjustments');
        Schema::dropIfExists('inventory_events');
        Schema::dropIfExists('stock_layers');
        Schema::dropIfExists('location_stock');
        Schema::dropIfExists('branch_stock');
        Schema::dropIfExists('products');
        Schema::dropIfExists('brands');
        Schema::dropIfExists('categories');
        Schema::dropIfExists('units');
        Schema::dropIfExists('sync_tombstones');
        Schema::dropIfExists('sync_cursors');
        Schema::dropIfExists('device_sessions');
        Schema::dropIfExists('locations');
        Schema::dropIfExists('branches');
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['company_id', 'role', 'phone', 'is_active']);
        });
        Schema::dropIfExists('companies');
    }
};
