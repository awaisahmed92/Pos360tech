<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ledger_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('code', 20);
            $table->string('name_en');
            $table->string('name_ur')->nullable();
            $table->string('type', 20);
            $table->uuid('parent_client_uuid')->nullable();
            $table->decimal('opening_balance', 14, 2)->default(0);
            $table->string('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->boolean('is_system')->default(false);
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
            $table->unique(['company_id', 'code']);
        });

        Schema::create('bank_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('name');
            $table->string('account_title')->nullable();
            $table->string('account_number', 60)->nullable();
            $table->decimal('opening_balance', 14, 2)->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('suppliers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('name');
            $table->string('phone', 40)->nullable();
            $table->string('address')->nullable();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('purchases', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->foreignId('supplier_id')->nullable()->constrained()->nullOnDelete();
            $table->string('supplier_name')->nullable();
            $table->string('invoice_no', 40)->nullable();
            $table->timestamp('occurred_at');
            $table->string('payment_method', 20)->default('cash');
            $table->decimal('paid', 14, 2)->default(0);
            $table->decimal('subtotal', 14, 2)->default(0);
            $table->decimal('tax', 14, 2)->default(0);
            $table->decimal('total', 14, 2)->default(0);
            $table->string('note')->nullable();
            $table->boolean('update_cost')->default(true);
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('purchase_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('purchase_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->decimal('qty', 14, 3);
            $table->decimal('unit_cost', 14, 4);
            $table->decimal('tax_percent', 8, 2)->default(0);
            $table->decimal('line_total', 14, 2);
            $table->decimal('new_sale_price', 14, 2)->nullable();
            $table->decimal('new_wholesale', 14, 2)->nullable();
            $table->string('batch_no', 40)->nullable();
            $table->date('expiry')->nullable();
        });

        Schema::create('purchase_returns', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('supplier_name')->nullable();
            $table->string('note')->nullable();
            $table->timestamp('occurred_at');
            $table->decimal('total', 14, 2)->default(0);
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('purchase_return_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('purchase_return_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->decimal('qty', 14, 3);
            $table->decimal('unit_cost', 14, 4)->default(0);
            $table->decimal('line_total', 14, 2)->default(0);
        });

        Schema::create('purchase_orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('supplier_name')->nullable();
            $table->date('occurred_on');
            $table->string('note')->nullable();
            $table->string('status', 20)->default('open');
            $table->json('lines');
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('purchase_payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->uuid('purchase_client_uuid');
            $table->decimal('amount', 14, 2);
            $table->string('method', 20)->default('cash');
            $table->date('occurred_on');
            $table->string('note')->nullable();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('purchase_payments');
        Schema::dropIfExists('purchase_orders');
        Schema::dropIfExists('purchase_return_lines');
        Schema::dropIfExists('purchase_returns');
        Schema::dropIfExists('purchase_lines');
        Schema::dropIfExists('purchases');
        Schema::dropIfExists('suppliers');
        Schema::dropIfExists('bank_accounts');
        Schema::dropIfExists('ledger_accounts');
    }
};
