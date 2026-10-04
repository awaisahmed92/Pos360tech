<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use PDO;
use RuntimeException;

/**
 * One client row in hr360_master.tenants, shared by HR360, Accounts360tech, and POS360tech.
 * Signing up in POS creates that row, or turns pos_app on when HR or Accounts already created it.
 */
class MasterClientRegistry
{
    public const RESERVED = [
        'demo', 'master', 'admin', 'administrator', 'api', 'www', 'app', 'root',
        'hr360', 'pos', 'pos360', 'accounts', 'test', 'mysql', 'sys', 'public',
        'information_schema', 'performance_schema', 'null', 'undefined', 'signup', 'login',
    ];

    private static bool $mysqlReady = false;

    public static function normalize(string $raw): string
    {
        $code = strtolower(trim($raw));
        $code = preg_replace('/[^a-z0-9]+/', '', $code) ?? '';

        return substr($code, 0, 40);
    }

    public function ensureSchema(): void
    {
        if (config('database.connections.master.driver') === 'sqlite') {
            $this->ensureSqlite();

            return;
        }

        if (self::$mysqlReady) {
            return;
        }

        $this->ensureMysql();
        self::$mysqlReady = true;
    }

    public function find(string $code): ?object
    {
        $this->ensureSchema();

        return DB::connection('master')->table('tenants')
            ->where(function ($query) use ($code) {
                $query->where('subdomain', $code)->orWhere('company_code', $code);
            })
            ->first();
    }

    public function posTaken(string $code): bool
    {
        $row = $this->find($code);

        return $row !== null && (int) ($row->pos_app ?? 0) === 1;
    }

    /**
     * @param  array{company_name: string, company_code: string, contact_name: string, designation?: ?string, industry?: ?string, country?: ?string, email: string, phone?: ?string}  $input
     * @return array{id: int, created: bool}
     */
    public function claimForPos(array $input): array
    {
        $this->ensureSchema();

        return DB::connection('master')->transaction(function () use ($input) {
            $code = $input['company_code'];
            $row = DB::connection('master')->table('tenants')
                ->where(function ($query) use ($code) {
                    $query->where('subdomain', $code)->orWhere('company_code', $code);
                })
                ->lockForUpdate()
                ->first();

            if ($row && (int) ($row->pos_app ?? 0) === 1) {
                throw ValidationException::withMessages([
                    'company_code' => 'That company code is already registered for POS360tech.',
                ]);
            }

            if ($row) {
                $update = [
                    'pos_app' => 1,
                    'status' => 'active',
                ];
                if (empty($row->pos_db_name)) {
                    $update['pos_db_name'] = $this->posDatabaseName();
                }
                if (empty($row->company_code)) {
                    $update['company_code'] = $code;
                }
                foreach ([
                    'industry' => $input['industry'] ?? null,
                    'country' => $input['country'] ?? null,
                    'contact_name' => $input['contact_name'],
                    'contact_designation' => $input['designation'] ?? null,
                    'contact_email' => $input['email'],
                    'contact_phone' => $input['phone'] ?? null,
                ] as $column => $value) {
                    if ($value !== null && $value !== '' && empty($row->{$column})) {
                        $update[$column] = $value;
                    }
                }
                DB::connection('master')->table('tenants')->where('id', $row->id)->update($update);
                $this->rememberAdmin((int) $row->id, $input);

                return ['id' => (int) $row->id, 'created' => false];
            }

            $id = (int) DB::connection('master')->table('tenants')->insertGetId([
                'name' => $input['company_name'],
                'subdomain' => $code,
                'company_code' => $code,
                'db_host' => (string) env('DB_HOST', '127.0.0.1'),
                'db_name' => 'pos360_'.$code,
                'pos_db_name' => $this->posDatabaseName(),
                'db_user' => (string) env('DB_USERNAME', 'root'),
                'db_password' => (string) env('DB_PASSWORD', ''),
                'status' => 'active',
                'hr_app' => 0,
                'accounts_app' => 0,
                'pos_app' => 1,
                'industry' => $input['industry'] ?? null,
                'country' => $input['country'] ?? null,
                'contact_name' => $input['contact_name'],
                'contact_designation' => $input['designation'] ?? null,
                'contact_email' => $input['email'],
                'contact_phone' => $input['phone'] ?? null,
                'source' => 'pos_signup',
                'created_at' => now(),
            ]);
            $this->rememberAdmin($id, $input);

            return ['id' => $id, 'created' => true];
        });
    }

    public function releasePosClaim(int $tenantId, bool $created): void
    {
        $master = DB::connection('master');
        if ($created) {
            $master->table('tenant_admins')->where('tenant_id', $tenantId)->delete();
            $master->table('tenants')->where('id', $tenantId)->delete();

            return;
        }

        $master->table('tenants')->where('id', $tenantId)->update([
            'pos_app' => 0,
            'pos_db_name' => null,
        ]);
    }

    private function rememberAdmin(int $tenantId, array $input): void
    {
        $email = strtolower(trim($input['email']));
        $exists = DB::connection('master')->table('tenant_admins')
            ->where('tenant_id', $tenantId)
            ->where('email', $email)
            ->exists();
        if ($exists) {
            return;
        }

        DB::connection('master')->table('tenant_admins')->insert([
            'tenant_id' => $tenantId,
            'name' => $input['contact_name'],
            'designation' => $input['designation'] ?? null,
            'email' => $email,
            'user_name' => $input['contact_name'],
            'created_at' => now(),
        ]);
    }

    private function posDatabaseName(): string
    {
        $name = (string) env('DB_DATABASE', 'pos360tech');

        return ($name === '' || $name === ':memory:') ? 'pos360tech' : $name;
    }

    private function ensureSqlite(): void
    {
        $db = DB::connection('master');
        $db->statement('CREATE TABLE IF NOT EXISTS tenants (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name VARCHAR(191) NOT NULL,
            subdomain VARCHAR(100) NOT NULL,
            company_code VARCHAR(100) NULL,
            db_host VARCHAR(191) NOT NULL DEFAULT \'localhost\',
            db_name VARCHAR(191) NOT NULL,
            accounts_db_name VARCHAR(191) NULL,
            pos_db_name VARCHAR(191) NULL,
            school_db_name VARCHAR(191) NULL,
            db_user VARCHAR(191) NOT NULL DEFAULT \'root\',
            db_password VARCHAR(191) NOT NULL DEFAULT \'\',
            status VARCHAR(20) NOT NULL DEFAULT \'active\',
            hr_app INTEGER NOT NULL DEFAULT 0,
            accounts_app INTEGER NOT NULL DEFAULT 0,
            pos_app INTEGER NOT NULL DEFAULT 0,
            school_app INTEGER NOT NULL DEFAULT 0,
            industry VARCHAR(120) NULL,
            country VARCHAR(120) NULL,
            contact_name VARCHAR(191) NULL,
            contact_designation VARCHAR(191) NULL,
            contact_email VARCHAR(191) NULL,
            contact_phone VARCHAR(60) NULL,
            source VARCHAR(40) NOT NULL DEFAULT \'manual\',
            created_at TIMESTAMP NULL
        )');
        $db->statement('CREATE TABLE IF NOT EXISTS tenant_admins (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id INTEGER NOT NULL,
            name VARCHAR(191) NOT NULL,
            designation VARCHAR(191) NULL,
            email VARCHAR(191) NOT NULL,
            user_name VARCHAR(100) NOT NULL,
            employee_id INTEGER NULL,
            created_at TIMESTAMP NULL
        )');
    }

    private function ensureMysql(): void
    {
        $cfg = config('database.connections.master');
        $dbName = (string) ($cfg['database'] ?? 'hr360_master');
        if (! preg_match('/^[A-Za-z0-9_]+$/', $dbName)) {
            throw new RuntimeException('The master database name is not valid.');
        }

        $pdo = new PDO(
            'mysql:host='.$cfg['host'].';port='.$cfg['port'].';charset=utf8mb4',
            (string) $cfg['username'],
            (string) ($cfg['password'] ?? ''),
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
        );
        $pdo->exec("CREATE DATABASE IF NOT EXISTS `{$dbName}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");

        $master = DB::connection('master');
        $master->statement("CREATE TABLE IF NOT EXISTS `tenants` (
            `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
            `name` VARCHAR(191) NOT NULL,
            `subdomain` VARCHAR(100) NOT NULL,
            `db_host` VARCHAR(191) NOT NULL DEFAULT 'localhost',
            `db_name` VARCHAR(191) NOT NULL,
            `accounts_db_name` VARCHAR(191) NULL,
            `pos_db_name` VARCHAR(191) NULL,
            `school_db_name` VARCHAR(191) NULL,
            `db_user` VARCHAR(191) NOT NULL DEFAULT 'root',
            `db_password` VARCHAR(191) NOT NULL DEFAULT '',
            `status` ENUM('active','inactive','suspended') NOT NULL DEFAULT 'active',
            `hr_app` TINYINT(1) NOT NULL DEFAULT 1,
            `accounts_app` TINYINT(1) NOT NULL DEFAULT 0,
            `pos_app` TINYINT(1) NOT NULL DEFAULT 0,
            `school_app` TINYINT(1) NOT NULL DEFAULT 0,
            `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
            `company_code` VARCHAR(100) NULL,
            `industry` VARCHAR(120) NULL,
            `country` VARCHAR(120) NULL,
            `contact_name` VARCHAR(191) NULL,
            `contact_designation` VARCHAR(191) NULL,
            `contact_email` VARCHAR(191) NULL,
            `contact_phone` VARCHAR(60) NULL,
            `source` VARCHAR(40) NOT NULL DEFAULT 'manual',
            PRIMARY KEY (`id`),
            UNIQUE KEY `uq_tenants_subdomain` (`subdomain`),
            KEY `idx_tenants_company_code` (`company_code`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

        $master->statement("CREATE TABLE IF NOT EXISTS `tenant_admins` (
            `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
            `tenant_id` INT UNSIGNED NOT NULL,
            `name` VARCHAR(191) NOT NULL,
            `designation` VARCHAR(191) NULL,
            `email` VARCHAR(191) NOT NULL,
            `user_name` VARCHAR(100) NOT NULL,
            `employee_id` INT UNSIGNED NULL,
            `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `idx_tenant_admins_tenant` (`tenant_id`),
            KEY `idx_tenant_admins_email` (`email`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

        $present = collect($master->select('SHOW COLUMNS FROM `tenants`'))->pluck('Field')->all();
        $missing = [
            'accounts_db_name' => 'VARCHAR(191) NULL',
            'pos_db_name' => 'VARCHAR(191) NULL',
            'school_db_name' => 'VARCHAR(191) NULL',
            'accounts_app' => 'TINYINT(1) NOT NULL DEFAULT 0',
            'pos_app' => 'TINYINT(1) NOT NULL DEFAULT 0',
            'school_app' => 'TINYINT(1) NOT NULL DEFAULT 0',
            'company_code' => 'VARCHAR(100) NULL',
            'industry' => 'VARCHAR(120) NULL',
            'country' => 'VARCHAR(120) NULL',
            'contact_name' => 'VARCHAR(191) NULL',
            'contact_designation' => 'VARCHAR(191) NULL',
            'contact_email' => 'VARCHAR(191) NULL',
            'contact_phone' => 'VARCHAR(60) NULL',
            'source' => "VARCHAR(40) NOT NULL DEFAULT 'manual'",
        ];
        foreach ($missing as $column => $definition) {
            if (! in_array($column, $present, true)) {
                $master->statement("ALTER TABLE `tenants` ADD COLUMN `{$column}` {$definition}");
            }
        }
    }
}
