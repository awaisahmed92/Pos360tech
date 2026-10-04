<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * MariaDB without explicit_defaults_for_timestamp gives the first TIMESTAMP column
     * ON UPDATE CURRENT_TIMESTAMP, which rewrites business dates on every save.
     */
    private array $columns = [
        'inventory_events' => 'occurred_at',
        'location_moves' => 'occurred_at',
        'purchases' => 'occurred_at',
        'purchase_returns' => 'occurred_at',
        'sales' => 'occurred_at',
        'stock_adjustments' => 'occurred_at',
        'stock_layers' => 'received_at',
        'stock_transfers' => 'occurred_at',
        'stock_write_offs' => 'occurred_at',
    ];

    public function up(): void
    {
        if (! in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            return;
        }

        foreach ($this->columns as $table => $column) {
            $info = DB::selectOne(
                'SELECT IS_NULLABLE, EXTRA FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?',
                [$table, $column]
            );
            if (! $info || ! str_contains(strtolower((string) $info->EXTRA), 'on update')) {
                continue;
            }

            $null = $info->IS_NULLABLE === 'YES' ? 'NULL DEFAULT NULL' : 'NOT NULL DEFAULT CURRENT_TIMESTAMP';
            DB::statement("ALTER TABLE `{$table}` MODIFY `{$column}` TIMESTAMP {$null}");

            // Rows touched by an UPDATE were stamped with the local clock; created_at holds the real moment.
            DB::statement("UPDATE `{$table}` SET `{$column}` = `created_at` WHERE `{$column}` > `created_at` + INTERVAL 1 HOUR");
        }
    }

    public function down(): void
    {
    }
};
