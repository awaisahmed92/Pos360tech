<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sales', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('party_name')->nullable();
            $table->string('invoice_no')->nullable();
            $table->timestamp('occurred_at');
            $table->string('payment_method', 20)->default('cash');
            $table->decimal('paid', 14, 2)->default(0);
            $table->decimal('total', 14, 2)->default(0);
            $table->string('note')->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('sale_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sale_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->nullable()->constrained()->nullOnDelete();
            $table->string('line_name')->nullable();
            $table->boolean('is_return')->default(false);
            $table->decimal('discount', 14, 2)->default(0);
            $table->decimal('qty', 14, 3);
            $table->decimal('unit_price', 14, 2)->default(0);
            $table->decimal('unit_cost', 14, 4)->default(0);
            $table->decimal('line_total', 14, 2)->default(0);
        });

        Schema::create('expenses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->date('occurred_on');
            $table->string('invoice_no')->nullable();
            $table->uuid('account_client_uuid')->nullable();
            $table->string('account_name');
            $table->string('narration')->nullable();
            $table->decimal('amount', 14, 2);
            $table->string('method', 20)->default('cash');
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('employees', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->string('name');
            $table->string('name_ur')->nullable();
            $table->string('phone', 40)->nullable();
            $table->string('cnic', 20)->nullable();
            $table->string('designation')->nullable();
            $table->string('employment_type', 20)->default('full_time');
            $table->decimal('monthly_salary', 14, 2)->default(0);
            $table->date('joined_on')->nullable();
            $table->decimal('commission_rate', 8, 2)->default(0);
            $table->string('commission_on', 20)->default('none');
            $table->string('status', 20)->default('active');
            $table->text('notes')->nullable();
            $table->boolean('allow_login')->default(false);
            $table->string('email')->nullable();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('attendance_marks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->uuid('employee_client_uuid');
            $table->date('work_date');
            $table->string('status', 20)->default('present');
            $table->string('check_in', 10)->nullable();
            $table->string('check_out', 10)->nullable();
            $table->string('note')->nullable();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });

        Schema::create('salary_payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_uuid');
            $table->uuid('employee_client_uuid');
            $table->string('period', 7);
            $table->string('kind', 20)->default('salary');
            $table->decimal('amount', 14, 2);
            $table->string('method', 20)->default('cash');
            $table->date('paid_on');
            $table->string('note')->nullable();
            $table->timestamps();
            $table->unique(['company_id', 'client_uuid']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('salary_payments');
        Schema::dropIfExists('attendance_marks');
        Schema::dropIfExists('employees');
        Schema::dropIfExists('expenses');
        Schema::dropIfExists('sale_lines');
        Schema::dropIfExists('sales');
    }
};
