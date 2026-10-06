<?php

namespace App\Services;

use App\Contracts\Repositories\SettingRepositoryInterface;
use App\Contracts\Services\SettingServiceInterface;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;

class SettingService extends BaseService implements SettingServiceInterface
{
    public function __construct(SettingRepositoryInterface $repository)
    {
        parent::__construct($repository);
    }

    public function getSettings(): Collection
    {
        return Cache::remember('system_settings', 86400, function () {
            return $this->repository->all();
        });
    }

    public function updateSettings(array $settings): Collection
    {
        /** @var SettingRepositoryInterface $repo */
        $repo = $this->repository;

        foreach ($settings as $key => $value) {
            $repo->setKey($key, $value);
        }

        Cache::forget('system_settings');

        return $this->getSettings();
    }
}
