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
        return $authenticatedUser->hasAnyRole(['Chairman', 'Dean', 'Vice Chancellor', 'Admin', 'Coordinator', 'Batch Adviser', 'Student']);
    }

    public function view(User $authenticatedUser, User $targetUser): bool
    {
        return $authenticatedUser->id === $targetUser->id ||
               $authenticatedUser->hasAnyRole(['Chairman', 'Batch Adviser', 'Coordinator', 'Admin']);
    }

    public function createStaff(User $authenticatedUser): bool
    {
        return $authenticatedUser->hasAnyRole(['Admin', 'Chairman', 'Coordinator']);
    }

    public function updateStaff(User $authenticatedUser, User $targetUser): bool
    {
        return $authenticatedUser->hasAnyRole(['Admin', 'Chairman', 'Coordinator']);
    }

    public function deleteStaff(User $authenticatedUser, User $targetUser): bool
    {
        return $authenticatedUser->hasAnyRole(['Admin', 'Chairman', 'Coordinator']);
    }

    public function assignRole(User $authenticatedUser): bool
    {
        return $authenticatedUser->hasAnyRole(['Admin', 'Chairman', 'Coordinator']);
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
