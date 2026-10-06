<?php

namespace App\Contracts\Services;

use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;

interface UserServiceInterface
{
    public function createStaff(array $data): User;

    public function updateStaff(User $user, array $data): User;

    public function deleteStaff(User $user): void;

    public function listUsers(array $filters = [], int $perPage = 15): LengthAwarePaginator;

    public function listStaff(array $filters = [], int $perPage = 15): LengthAwarePaginator;

    public function getUserDetails(User $user): User;

    public function assignRoles(User $user, array $roles): User;

    public function assignAdviser(User $user, int|string $adviserId): User;

    public function assignSections(User $user, array $sectionIds): User;

    public function updateCrStatus(User $user, bool $isCr): User;
}
