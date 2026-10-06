<?php

namespace App\Repositories;

use App\Contracts\Repositories\SettingRepositoryInterface;
use App\Models\Setting;
use Illuminate\Support\Collection;

class SettingRepository extends BaseRepository implements SettingRepositoryInterface
{
    public function __construct(Setting $model)
    {
        parent::__construct($model);
    }

    public function getByKey(string $key): ?Setting
    {
        return $this->model->where('key', $key)->first();
    }

    public function getGroup(string $group): Collection
    {
        return $this->model->where('group', $group)->get();
    }

    public function setKey(string $key, mixed $value, string $group = 'general'): Setting
    {
        return $this->model->updateOrCreate(
            ['key' => $key],
            ['value' => is_array($value) ? json_encode($value) : $value, 'group' => $group]
        );
    }
}
