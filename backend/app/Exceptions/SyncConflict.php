<?php

namespace App\Exceptions;

use RuntimeException;

class SyncConflict extends RuntimeException
{
    public function __construct(public array $record)
    {
        parent::__construct('The server has a newer copy of this record.');
    }
}
