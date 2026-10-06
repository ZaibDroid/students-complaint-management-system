<?php

namespace App\Contracts\Repositories;

use App\Models\Application;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;

interface ApplicationRepositoryInterface extends BaseRepositoryInterface
{
    public function getApplicationsForUser(User $user, array $filters = [], int $perPage = 15): LengthAwarePaginator;

    public function lockForUpdate(int $id): ?Application;
    public function findByTicketNumber(string $ticketNumber): ?Application;
}
