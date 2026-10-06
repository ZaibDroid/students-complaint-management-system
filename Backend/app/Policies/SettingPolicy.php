<?php

namespace App\Policies;

use App\Models\User;

class SettingPolicy
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

    public function update(User $user): bool
    {
        return $user->hasRole('Admin');
    }
}
