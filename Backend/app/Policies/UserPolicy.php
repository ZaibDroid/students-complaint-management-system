<?php

namespace App\Policies;

use App\Models\User;

class UserPolicy
{
    public function before(User $authenticatedUser, string $ability): ?bool
    {
        if ($authenticatedUser->hasRole('Admin')) {
            return true;
        }

        return null;
    }

    public function viewAny(User $authenticatedUser): bool
    {
        return true;
    }

    public function view(User $authenticatedUser, User $targetUser): bool
    {
        return true;
    }

    public function createStaff(User $authenticatedUser): bool
    {
        return $authenticatedUser->hasAnyRole(['Admin', 'Chairman', 'Coordinator', 'Dean', 'Vice Chancellor']);
    }

    public function updateStaff(User $authenticatedUser, User $targetUser): bool
    {
        return $authenticatedUser->hasAnyRole(['Admin', 'Chairman', 'Coordinator', 'Dean', 'Vice Chancellor']);
    }

    public function deleteStaff(User $authenticatedUser, User $targetUser): bool
    {
        return $authenticatedUser->hasAnyRole(['Admin', 'Chairman', 'Coordinator', 'Dean', 'Vice Chancellor']);
    }

    public function assignRole(User $authenticatedUser): bool
    {
        return $authenticatedUser->hasAnyRole(['Admin', 'Chairman', 'Coordinator', 'Dean', 'Vice Chancellor']);
    }

    public function assignAdviser(User $authenticatedUser): bool
    {
        return $authenticatedUser->hasAnyRole(['Admin', 'Chairman', 'Coordinator', 'Student']);
    }

    public function manageCr(User $authenticatedUser): bool
    {
        return $authenticatedUser->hasAnyRole(['Admin', 'Chairman', 'Coordinator', 'Batch Adviser']);
    }
}
