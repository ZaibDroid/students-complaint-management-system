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
        if ($authenticatedUser->hasRole('Admin')) {
            return true;
        }

        // Both users must belong to a defined department
        if (empty($authenticatedUser->department_id) || empty($targetUser->department_id)) {
            return false;
        }

        // Department IDs must strictly match
        if ((int)$authenticatedUser->department_id !== (int)$targetUser->department_id) {
            return false;
        }

        // Chairman can manage Coordinators, Batch Advisers, and Office Staff in their own department
        if ($authenticatedUser->hasRole('Chairman')) {
            return !$targetUser->hasAnyRole(['Admin', 'Chairman']);
        }

        // Coordinator can only manage Batch Advisers or Office Staff in their own department
        if ($authenticatedUser->hasRole('Coordinator')) {
            return !$targetUser->hasAnyRole(['Admin', 'Chairman', 'Coordinator']);
        }

        return false;
    }

    public function deleteStaff(User $authenticatedUser, User $targetUser): bool
    {
        // Users cannot delete their own account via staff management
        if ((int)$authenticatedUser->id === (int)$targetUser->id) {
            return false;
        }

        return $this->updateStaff($authenticatedUser, $targetUser);
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
