<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sale_lines', function (Blueprint $table) {
            if (! Schema::hasColumn('sale_lines', 'line_name')) {
                $table->string('line_name')->nullable()->after('product_id');
            }
            if (! Schema::hasColumn('sale_lines', 'is_return')) {
                $table->boolean('is_return')->default(false)->after('line_name');
            }
            if (! Schema::hasColumn('sale_lines', 'discount')) {
                $table->decimal('discount', 14, 2)->default(0)->after('is_return');
            }
        });

        $driver = Schema::getConnection()->getDriverName();
        if (! in_array($driver, ['mysql', 'mariadb'], true)) {
            return;
        }

        $column = DB::selectOne("SELECT IS_NULLABLE AS nullable_flag FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sale_lines' AND COLUMN_NAME = 'product_id'");
        if ($column && ($column->nullable_flag ?? 'YES') === 'NO') {
            DB::statement('ALTER TABLE sale_lines DROP FOREIGN KEY sale_lines_product_id_foreign');
            DB::statement('ALTER TABLE sale_lines MODIFY product_id BIGINT UNSIGNED NULL');
            DB::statement('ALTER TABLE sale_lines ADD CONSTRAINT sale_lines_product_id_foreign FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE SET NULL');
        }
    }

    public function down(): void
    {
        Schema::table('sale_lines', function (Blueprint $table) {
            if (Schema::hasColumn('sale_lines', 'discount')) {
                $table->dropColumn('discount');
            }
            if (Schema::hasColumn('sale_lines', 'is_return')) {
                $table->dropColumn('is_return');
            }
            if (Schema::hasColumn('sale_lines', 'line_name')) {
                $table->dropColumn('line_name');
            }
        });
    }
};
