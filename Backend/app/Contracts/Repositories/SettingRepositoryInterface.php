<?php

namespace App\Contracts\Repositories;

use App\Models\Setting;
use Illuminate\Support\Collection;

interface SettingRepositoryInterface extends BaseRepositoryInterface
{
    public function getByKey(string $key): ?Setting;

    public function getGroup(string $group): Collection;

    public function setKey(string $key, mixed $value, string $group = 'general'): Setting;
}
