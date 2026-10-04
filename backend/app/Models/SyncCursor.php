<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SyncCursor extends Model
{
    protected $fillable = [
        'company_id', 'user_id', 'device_id', 'cursor',
    ];
}
