<?php

namespace App\Services;

use App\Models\Branch;
use App\Models\Company;
use App\Models\DeviceSession;
use App\Models\LedgerAccount;
use App\Models\Location;
use App\Models\Unit;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class CompanyBootstrapService
{
    public function __construct(private readonly MasterClientRegistry $clients) {}

    public function register(array $data): array
    {
        $code = MasterClientRegistry::normalize($data['company_code'] ?? $data['company_name']);
        if (strlen($code) < 3) {
            throw ValidationException::withMessages([
                'company_code' => 'Company code needs at least 3 letters or digits.',
            ]);
        }
        if (in_array($code, MasterClientRegistry::RESERVED, true)) {
            throw ValidationException::withMessages([
                'company_code' => 'That company code is reserved. Please pick another.',
            ]);
        }

        $claim = null;
        try {
            $claim = $this->clients->claimForPos([
                'company_name' => $data['company_name'],
                'company_code' => $code,
                'contact_name' => $data['name'],
                'designation' => $data['designation'] ?? null,
                'industry' => $data['industry'] ?? null,
                'country' => $data['country'] ?? null,
                'email' => strtolower(trim($data['email'])),
                'phone' => $data['phone'] ?? null,
            ]);

            return DB::transaction(function () use ($data, $claim, $code) {
            $company = Company::create([
                'name' => $data['company_name'],
                'company_code' => $code,
                'master_tenant_id' => $claim['id'],
                'currency_code' => 'PKR',
                'currency_symbol' => 'Rs',
                'subscription_status' => 'trial',
                'trial_ends_at' => now()->addDays(7),
            ]);

            $user = User::create([
                'company_id' => $company->id,
                'name' => $data['name'],
                'username' => $data['name'],
                'email' => $data['email'],
                'password' => $data['password'],
                'role' => 'owner',
                'phone' => $data['phone'] ?? null,
                'is_active' => true,
            ]);

            $branch = $this->makeBranch($company->id, 'Main Branch', 'MAIN', true, (string) Str::uuid());
            $this->seedUnits($company->id);
            $this->seedChartIfMissing($company->id);
            $this->touchDevice($user, $data['device_id'], $data['device_name'] ?? null);

            $token = $user->createToken('device:'.$data['device_id'])->plainTextToken;

            return $this->sessionPayload($user, $company, $token);
            });
        } catch (\Throwable $e) {
            if ($claim !== null) {
                $this->clients->releasePosClaim($claim['id'], $claim['created']);
            }
            throw $e;
        }
    }

    public function login(array $data): array
    {
        if (! empty($data['company_code']) || ! empty($data['username'])) {
            $user = $this->userForCompanyLogin($data);
        } else {
            $user = User::query()->where('email', $data['email'] ?? '')->first();
        }

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => 'These credentials do not match our records.',
            ]);
        }

        if (! $user->is_active) {
            throw ValidationException::withMessages([
                'email' => 'This user is inactive.',
            ]);
        }

        $this->touchDevice($user, $data['device_id'], $data['device_name'] ?? null);
        $token = $user->createToken('device:'.$data['device_id'])->plainTextToken;

        return $this->sessionPayload($user, $user->company, $token);
    }

    private function userForCompanyLogin(array $data): ?User
    {
        $code = MasterClientRegistry::normalize((string) ($data['company_code'] ?? ''));
        $username = trim((string) ($data['username'] ?? ''));
        if ($code === '' || $username === '') {
            throw ValidationException::withMessages([
                'company_code' => 'Company name and user name are required.',
            ]);
        }

        $company = Company::query()->where('company_code', $code)->first();
        if (! $company) {
            return null;
        }

        $needle = strtolower($username);

        return User::query()
            ->where('company_id', $company->id)
            ->where(function ($query) use ($needle) {
                $query->whereRaw('lower(username) = ?', [$needle])
                    ->orWhereRaw('lower(name) = ?', [$needle])
                    ->orWhereRaw('lower(email) = ?', [$needle]);
            })
            ->first();
    }

    public function sessionPayload(User $user, ?Company $company, ?string $token = null): array
    {
        $company = $company ?: $user->company;
        $branches = Branch::query()->where('company_id', $user->company_id)->orderByDesc('is_main')->orderBy('name')->get();
        $locations = Location::query()->with('branch')->where('company_id', $user->company_id)->orderBy('name')->get();

        $payload = [
            'user' => $user->toApiArray(),
            'company' => $company?->toApiArray(),
            'branches' => $branches->map->toSyncArray()->values(),
            'locations' => $locations->map->toSyncArray()->values(),
        ];

        if ($token !== null) {
            $payload['token'] = $token;
        }

        return $payload;
    }

    public function makeBranch(int $companyId, string $name, ?string $code, bool $isMain, string $clientUuid, ?string $locationUuid = null): Branch
    {
        $branch = Branch::create([
            'company_id' => $companyId,
            'client_uuid' => $clientUuid,
            'name' => $name,
            'code' => $code,
            'is_main' => $isMain,
            'is_active' => true,
        ]);

        Location::create([
            'company_id' => $companyId,
            'branch_id' => $branch->id,
            'client_uuid' => $locationUuid ?: (string) Str::uuid(),
            'name' => 'Main Godown',
            'is_default' => true,
            'is_active' => true,
        ]);

        return $branch;
    }

    public function touchDevice(User $user, string $deviceId, ?string $deviceName): void
    {
        DeviceSession::query()->updateOrCreate(
            ['user_id' => $user->id, 'device_id' => $deviceId],
            [
                'company_id' => $user->company_id,
                'device_name' => $deviceName,
                'last_seen_at' => now(),
            ],
        );
    }

    public function seedChartIfMissing(int $companyId): void
    {
        if (LedgerAccount::query()->where('company_id', $companyId)->exists()) {
            return;
        }

        $rows = [
            ['1000', 'Cash', 'نقد', 'asset'],
            ['1100', 'Bank', 'بینک', 'asset'],
            ['1200', 'Accounts Receivable', 'وصول طلب', 'asset'],
            ['1300', 'Inventory', 'اسٹاک', 'asset'],
            ['1400', 'Staff Advances', 'عملے کا ایڈوانس', 'asset'],
            ['2000', 'Accounts Payable', 'قابل ادائیگی', 'liability'],
            ['2100', 'Sales Tax Payable', 'سیلز ٹیکس قابل ادائیگی', 'liability'],
            ['3000', 'Capital', 'سرمایہ', 'equity'],
            ['3100', "Owner's Drawings", 'مالک کے نکاسی', 'equity'],
            ['4000', 'Sales Revenue', 'فروخت', 'income'],
            ['4100', 'Other Income', 'دیگر آمدنی', 'income'],
            ['5000', 'Cost of Goods Sold', 'فروخت شدہ مال کی لاگت', 'expense'],
            ['5100', 'Salaries & Wages', 'تنخواہیں', 'expense'],
            ['5200', 'Rent', 'کرایہ', 'expense'],
        ];

        foreach ($rows as [$code, $en, $ur, $type]) {
            LedgerAccount::create([
                'company_id' => $companyId,
                'client_uuid' => self::systemAccountUuid($code),
                'code' => $code,
                'name_en' => $en,
                'name_ur' => $ur,
                'type' => $type,
                'opening_balance' => 0,
                'is_active' => true,
                'is_system' => true,
            ]);
        }
    }

    public static function systemAccountUuid(string $code): string
    {
        return sprintf('10000000-0000-4000-8000-%012d', (int) $code);
    }

    private function seedUnits(int $companyId): void
    {
        $units = [
            ['Bag', 'بوری', 'bag'],
            ['Bottle', 'بوتل', 'btl'],
            ['Bundle', 'گٹھی', 'bnd'],
            ['Can', 'کین', 'can'],
            ['Dozen', 'درجن', 'dz'],
            ['Foot', 'فٹ', 'ft'],
            ['Piece', 'عدد', 'pc'],
            ['Kg', 'کلو', 'kg'],
        ];

        foreach ($units as [$en, $ur, $short]) {
            Unit::create([
                'company_id' => $companyId,
                'client_uuid' => (string) Str::uuid(),
                'name_en' => $en,
                'name_ur' => $ur,
                'short_name' => $short,
            ]);
        }
    }
}
