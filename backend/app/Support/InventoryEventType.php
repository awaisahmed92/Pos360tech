<?php

namespace App\Support;

class InventoryEventType
{
    public const OPENING = 'opening';

    public const ADJUSTMENT_IN = 'adjustment_in';

    public const ADJUSTMENT_OUT = 'adjustment_out';

    public const WRITE_OFF = 'write_off';

    public const TRANSFER_OUT = 'transfer_out';

    public const TRANSFER_IN = 'transfer_in';

    public const LOCATION_MOVE = 'location_move';

    public const PURCHASE = 'purchase';

    public const PURCHASE_RETURN = 'purchase_return';

    public const SALE = 'sale';

    public const SALE_RETURN = 'sale_return';

    public const MANUFACTURE_CONSUME = 'manufacture_consume';

    public const MANUFACTURE_PRODUCE = 'manufacture_produce';

    public const ALL = [
        self::OPENING,
        self::ADJUSTMENT_IN,
        self::ADJUSTMENT_OUT,
        self::WRITE_OFF,
        self::TRANSFER_OUT,
        self::TRANSFER_IN,
        self::LOCATION_MOVE,
        self::PURCHASE,
        self::PURCHASE_RETURN,
        self::SALE,
        self::SALE_RETURN,
        self::MANUFACTURE_CONSUME,
        self::MANUFACTURE_PRODUCE,
    ];
}
