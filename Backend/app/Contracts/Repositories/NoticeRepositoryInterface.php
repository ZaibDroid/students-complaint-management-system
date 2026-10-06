<?php

namespace App\Contracts\Repositories;

use App\Models\Notice;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;

interface NoticeRepositoryInterface extends BaseRepositoryInterface
{
    public function getNoticesForUser(User $user, array $filters = [], int $perPage = 15): LengthAwarePaginator;

    public function lockForUpdate(int $id): ?Notice;
}
