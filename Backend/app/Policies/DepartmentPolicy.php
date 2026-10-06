<?php

namespace App\Policies;

use App\Models\User;

class DepartmentPolicy
{
    public function before(User $user, string $ability): ?bool
    {
        if ($user->hasRole('Admin')) {
            return true;
        }

        return null;
    }

    public function viewAny(?User $user): bool
    {
        return true;
    }

    public function view(?User $user): bool
    {
        return true;
    }

    public function create(User $user): bool
    {
        return $user->hasRole('Admin');
    }

    public function update(User $user): bool
    {
        return $user->hasRole('Admin');
    }

    public function delete(User $user): bool
    {
        return $user->hasRole('Admin');
    }
}
