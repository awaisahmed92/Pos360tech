<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            $table->string('company_code', 40)->nullable()->unique()->after('name');
            $table->unsignedBigInteger('master_tenant_id')->nullable()->index()->after('company_code');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->string('username', 120)->nullable()->after('name');
            $table->index(['company_id', 'username']);
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['company_id', 'username']);
            $table->dropColumn('username');
        });

        Schema::table('companies', function (Blueprint $table) {
            $table->dropUnique(['company_code']);
            $table->dropColumn(['company_code', 'master_tenant_id']);
        });
    }
};
