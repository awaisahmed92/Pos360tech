<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('purchase_returns', function (Blueprint $table) {
            $table->string('refund_method', 30)->default('payable')->after('supplier_name');
            $table->uuid('source_client_uuid')->nullable()->after('refund_method');
        });

        Schema::create('areas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('name');
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('parties', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('type', 20);
            $table->string('name');
            $table->string('name_ur')->nullable();
            $table->string('phone', 40)->nullable();
            $table->string('route_day', 20)->nullable();
            $table->uuid('area_client_uuid')->nullable();
            $table->string('email')->nullable();
            $table->string('cnic', 20)->nullable();
            $table->string('ntn', 30)->nullable();
            $table->string('strn', 30)->nullable();
            $table->decimal('opening_balance', 14, 2)->default(0);
            $table->string('balance_side', 20)->default('they_owe');
            $table->string('price_mode', 20)->default('ask');
            $table->string('address')->nullable();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('credit_recoveries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->uuid('party_client_uuid');
            $table->date('occurred_on');
            $table->decimal('amount', 14, 2);
            $table->string('method', 20)->default('cash');
            $table->string('note')->nullable();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('manufacturing_products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('code', 40)->nullable();
            $table->string('barcode', 40)->nullable();
            $table->string('name');
            $table->uuid('unit_client_uuid')->nullable();
            $table->decimal('qty', 14, 3)->default(1);
            $table->decimal('sale_price', 14, 2)->default(0);
            $table->decimal('wholesale_price', 14, 2)->default(0);
            $table->string('description')->nullable();
            $table->json('packaging')->nullable();
            $table->json('materials')->nullable();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('manufacturing_products');
        Schema::dropIfExists('credit_recoveries');
        Schema::dropIfExists('parties');
        Schema::dropIfExists('areas');
        Schema::table('purchase_returns', function (Blueprint $table) {
            $table->dropColumn(['refund_method', 'source_client_uuid']);
        });
    }
};
