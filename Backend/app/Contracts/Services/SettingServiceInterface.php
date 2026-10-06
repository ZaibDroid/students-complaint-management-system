<?php

namespace App\Contracts\Services;

use App\Models\Setting;
use Illuminate\Support\Collection;

interface SettingServiceInterface extends BaseServiceInterface
{
    public function getSettings(): Collection;

    public function updateSettings(array $settings): Collection;
}
