<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('journal_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->uuid('client_uuid');
            $table->string('invoice_no', 40)->nullable();
            $table->date('occurred_on');
            $table->string('narration');
            $table->string('category', 80)->nullable();
            $table->string('method', 20)->default('cash');
            $table->string('bank_name')->nullable();
            $table->decimal('debit', 14, 2)->default(0);
            $table->decimal('credit', 14, 2)->default(0);
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('day_closes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->date('closed_on');
            $table->decimal('opening_cash', 14, 2)->default(0);
            $table->decimal('counted_cash', 14, 2)->default(0);
            $table->string('note')->nullable();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
            $table->unique(['company_id', 'closed_on']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('day_closes');
        Schema::dropIfExists('journal_entries');
    }
};
