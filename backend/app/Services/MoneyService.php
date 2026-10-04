<?php

namespace App\Services;

use App\Models\Cheque;
use App\Models\DayClose;
use App\Models\InvestmentEntry;
use App\Models\InvestmentPartner;
use App\Models\JournalEntry;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class MoneyService
{
    public function __construct(private readonly CompanyLookup $lookup) {}

    public function apply(User $user, string $entity, string $action, array $payload): array
    {
        $record = match ($entity) {
            'cheque' => $this->cheque($user, $payload),
            'investment_partner' => $this->partner($user, $payload),
            'investment_entry' => $this->entry($user, $payload),
            'journal_entry' => $this->journal($user, $payload),
            'day_close' => $this->dayClose($user, $payload),
            default => throw ValidationException::withMessages(['entity' => 'Unknown money document.']),
        };

        return ['record' => $record];
    }

    private function cheque(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $existing = Cheque::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first();
            if ($existing) {
                return $existing->load('branch')->toSyncArray();
            }

            $direction = $payload['direction'] ?? 'in';
            if (! in_array($direction, ['in', 'out'], true)) {
                throw ValidationException::withMessages(['direction' => 'Choose cheque in or cheque out.']);
            }
            $status = $payload['status'] ?? 'pending';
            if (! in_array($status, ['pending', 'cleared', 'bounced'], true)) {
                throw ValidationException::withMessages(['status' => 'Status must be pending, cleared, or bounced.']);
            }

            $branchId = null;
            if (! empty($payload['branch_id']) || ! empty($payload['branch_client_uuid'])) {
                $branchId = $this->lookup->branch($user->company_id, $payload)->id;
            }

            $cheque = Cheque::create([
                'company_id' => $user->company_id,
                'branch_id' => $branchId,
                'client_uuid' => $uuid,
                'direction' => $direction,
                'cheque_no' => $this->required($payload, 'cheque_no', 'Cheque number'),
                'bank' => $this->nullable($payload, 'bank'),
                'party_name' => $this->nullable($payload, 'party_name'),
                'amount' => $this->money($payload, 'amount'),
                'issued_on' => $this->date($payload, 'issued_on', true),
                'cleared_on' => $this->date($payload, 'cleared_on', false),
                'status' => $status,
                'note' => $this->nullable($payload, 'note'),
            ]);

            return $cheque->load('branch')->toSyncArray();
        });
    }

    private function partner(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $partner = InvestmentPartner::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first()
                ?? new InvestmentPartner(['company_id' => $user->company_id, 'client_uuid' => $uuid]);

            $partner->fill([
                'name' => $this->required($payload, 'name', 'Partner name'),
                'phone' => $this->nullable($payload, 'phone'),
                'cnic' => $this->nullable($payload, 'cnic'),
                'joined_on' => $this->date($payload, 'joined_on', false),
                'address' => $this->nullable($payload, 'address'),
                'profit_share' => $this->percent($payload, 'profit_share'),
                'loss_share' => $this->percent($payload, 'loss_share'),
                'shares_loss' => ($payload['shares_loss'] ?? true) ? true : false,
                'is_owner' => ($payload['is_owner'] ?? false) ? true : false,
                'note' => $this->nullable($payload, 'note'),
            ]);
            $partner->save();

            return $partner->toSyncArray();
        });
    }

    private function entry(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $existing = InvestmentEntry::query()->with('partner')->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first();
            if ($existing) {
                return $existing->toSyncArray();
            }

            $kind = $payload['kind'] ?? 'in';
            if (! in_array($kind, ['in', 'out'], true)) {
                throw ValidationException::withMessages(['kind' => 'Choose money in or money out.']);
            }

            $partner = InvestmentPartner::query()
                ->where('company_id', $user->company_id)
                ->where('client_uuid', $payload['partner_client_uuid'] ?? '')
                ->first();
            if (! $partner) {
                throw ValidationException::withMessages(['partner' => 'Choose an owner or partner.']);
            }

            $entry = InvestmentEntry::create([
                'company_id' => $user->company_id,
                'partner_id' => $partner->id,
                'client_uuid' => $uuid,
                'kind' => $kind,
                'method' => in_array($payload['method'] ?? 'cash', ['cash', 'bank'], true) ? ($payload['method'] ?? 'cash') : 'cash',
                'amount' => $this->money($payload, 'amount'),
                'occurred_on' => $this->date($payload, 'occurred_on', true),
                'note' => $this->nullable($payload, 'note'),
            ]);

            return $entry->load('partner')->toSyncArray();
        });
    }

    private function journal(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $row = JournalEntry::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first();
            if ($row) {
                return $row->toSyncArray();
            }
            $debit = $this->nonNegative($payload, 'debit');
            $credit = $this->nonNegative($payload, 'credit');
            if ((float) $debit <= 0 && (float) $credit <= 0) {
                throw ValidationException::withMessages(['amount' => 'Enter a debit or a credit.']);
            }
            $branchId = null;
            if (! empty($payload['branch_id']) || ! empty($payload['branch_client_uuid'])) {
                $branchId = $this->lookup->branch($user->company_id, $payload)->id;
            }
            $entry = JournalEntry::create([
                'company_id' => $user->company_id,
                'branch_id' => $branchId,
                'client_uuid' => $uuid,
                'invoice_no' => $this->nullable($payload, 'invoice_no'),
                'occurred_on' => $this->date($payload, 'occurred_on', true),
                'narration' => $this->required($payload, 'narration', 'Narration'),
                'category' => $this->nullable($payload, 'category'),
                'method' => ($payload['method'] ?? 'cash') === 'bank' ? 'bank' : 'cash',
                'bank_name' => $this->nullable($payload, 'bank_name'),
                'debit' => $debit,
                'credit' => $credit,
            ]);

            return $entry->toSyncArray();
        });
    }

    private function dayClose(User $user, array $payload): array
    {
        return DB::transaction(function () use ($user, $payload) {
            $uuid = $this->uuid($payload);
            $existing = DayClose::query()->where('company_id', $user->company_id)->where('client_uuid', $uuid)->first();
            if ($existing) {
                return $existing->toSyncArray();
            }
            $closedOn = $this->date($payload, 'closed_on', true);
            $sameDay = DayClose::query()->where('company_id', $user->company_id)->whereDate('closed_on', $closedOn)->first();
            if ($sameDay) {
                return $sameDay->toSyncArray();
            }
            $row = DayClose::create([
                'company_id' => $user->company_id,
                'client_uuid' => $uuid,
                'closed_on' => $closedOn,
                'opening_cash' => $this->nonNegative($payload, 'opening_cash'),
                'counted_cash' => $this->nonNegative($payload, 'counted_cash'),
                'note' => $this->nullable($payload, 'note'),
            ]);

            return $row->toSyncArray();
        });
    }

    private function nonNegative(array $payload, string $key): string
    {
        $value = $payload[$key] ?? 0;
        if (! is_numeric($value) || (float) $value < 0) {
            throw ValidationException::withMessages([$key => 'Amount cannot be negative.']);
        }

        return number_format((float) $value, 2, '.', '');
    }

    private function uuid(array $payload): string
    {
        $uuid = trim((string) ($payload['client_uuid'] ?? ''));
        if ($uuid === '') {
            throw ValidationException::withMessages(['client_uuid' => 'A client id is required.']);
        }

        return $uuid;
    }

    private function required(array $payload, string $key, string $label): string
    {
        $value = trim((string) ($payload[$key] ?? ''));
        if ($value === '') {
            throw ValidationException::withMessages([$key => $label.' is required.']);
        }

        return $value;
    }

    private function nullable(array $payload, string $key): ?string
    {
        $value = trim((string) ($payload[$key] ?? ''));

        return $value === '' ? null : $value;
    }

    private function money(array $payload, string $key): string
    {
        $value = $payload[$key] ?? null;
        if (! is_numeric($value) || (float) $value <= 0) {
            throw ValidationException::withMessages([$key => 'Enter an amount greater than zero.']);
        }

        return number_format((float) $value, 2, '.', '');
    }

    private function percent(array $payload, string $key): string
    {
        $value = $payload[$key] ?? 0;
        if (! is_numeric($value) || (float) $value < 0 || (float) $value > 100) {
            throw ValidationException::withMessages([$key => 'Share must be between 0 and 100.']);
        }

        return number_format((float) $value, 2, '.', '');
    }

    private function date(array $payload, string $key, bool $required): ?string
    {
        $value = trim((string) ($payload[$key] ?? ''));
        if ($value === '') {
            if ($required) {
                throw ValidationException::withMessages([$key => 'Date is required.']);
            }

            return null;
        }

        return Carbon::parse($value)->toDateString();
    }
}
