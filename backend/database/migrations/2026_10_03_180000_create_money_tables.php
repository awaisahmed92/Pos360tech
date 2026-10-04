<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cheques', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->uuid('client_uuid');
            $table->string('direction', 8);
            $table->string('cheque_no', 60);
            $table->string('bank')->nullable();
            $table->string('party_name')->nullable();
            $table->decimal('amount', 14, 2);
            $table->date('issued_on');
            $table->date('cleared_on')->nullable();
            $table->string('status', 20)->default('pending');
            $table->string('note')->nullable();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('investment_partners', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('name');
            $table->string('phone', 40)->nullable();
            $table->string('cnic', 40)->nullable();
            $table->date('joined_on')->nullable();
            $table->string('address')->nullable();
            $table->decimal('profit_share', 6, 2)->default(0);
            $table->decimal('loss_share', 6, 2)->default(0);
            $table->boolean('shares_loss')->default(true);
            $table->boolean('is_owner')->default(false);
            $table->string('note')->nullable();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('investment_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('partner_id')->constrained('investment_partners')->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('kind', 8);
            $table->string('method', 20)->default('cash');
            $table->decimal('amount', 14, 2);
            $table->date('occurred_on');
            $table->string('note')->nullable();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('investment_entries');
        Schema::dropIfExists('investment_partners');
        Schema::dropIfExists('cheques');
    }
};
