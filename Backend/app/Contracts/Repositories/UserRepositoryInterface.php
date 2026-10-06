<?php

namespace App\Contracts\Repositories;

use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;

interface UserRepositoryInterface extends BaseRepositoryInterface
{
    public function findByEmail(string $email): ?User;

    public function getStaffMembers(array $filters = [], int $perPage = 15): LengthAwarePaginator;

    public function getUsers(array $filters = [], int $perPage = 15): LengthAwarePaginator;

    public function assignSectionsToUser(User $user, array $sectionIds): void;
}
