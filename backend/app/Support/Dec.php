<?php

namespace App\Support;

use Brick\Math\BigDecimal;
use Brick\Math\RoundingMode;

class Dec
{
    public static function of(mixed $value): BigDecimal
    {
        if ($value instanceof BigDecimal) {
            return $value;
        }

        if ($value === null || $value === '') {
            return BigDecimal::zero();
        }

        return BigDecimal::of((string) $value);
    }

    public static function qty(mixed $value): string
    {
        return (string) self::of($value)->toScale(3, RoundingMode::HALF_UP);
    }

    public static function cost(mixed $value): string
    {
        return (string) self::of($value)->toScale(4, RoundingMode::HALF_UP);
    }

    public static function money(mixed $value): string
    {
        return (string) self::of($value)->toScale(2, RoundingMode::HALF_UP);
    }

    public static function cmp(mixed $left, mixed $right): int
    {
        return self::of($left)->compareTo(self::of($right));
    }

    public static function mulMoney(mixed $qty, mixed $cost): string
    {
        return self::money(self::of($qty)->multipliedBy(self::of($cost)));
    }
}
