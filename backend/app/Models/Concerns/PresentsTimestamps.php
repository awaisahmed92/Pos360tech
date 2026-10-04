<?php

namespace App\Models\Concerns;

trait PresentsTimestamps
{
    protected function timestampPayload(): array
    {
        return [
            'created_at' => optional($this->created_at)->toJSON(),
            'updated_at' => optional($this->updated_at)->toJSON(),
        ];
    }
}
