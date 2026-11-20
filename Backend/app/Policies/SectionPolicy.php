<?php

namespace App\Policies;

use App\Models\Section;
use App\Models\User;

class SectionPolicy
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

    public function view(?User $user, ?Section $section = null): bool
    {
        return true;
    }

    public function create(User $user): bool
    {
        if ($user->hasRole('Admin') || $user->hasRole('Chairman')) {
            return true;
        }

        if ($user->hasRole('Coordinator')) {
            $batchId = request('batch_id') ?? request()->input('batch_id');
            if ($batchId) {
                $coordinatorBatchIds = $user->getAssignedBatchIds();
                return in_array((int)$batchId, $coordinatorBatchIds, true);
            }
            return false;
        }

        return false;
    }

    public function update(User $user, Section $section): bool
    {
        if ($user->hasRole('Admin')) {
            return true;
        }

        if ($user->hasRole('Chairman')) {
            return empty($user->department_id) 
                || empty($section->batch?->department_id) 
                || (int)$user->department_id === (int)$section->batch?->department_id;
        }

        if ($user->hasRole('Coordinator')) {
            $coordinatorBatchIds = $user->getAssignedBatchIds();
            return in_array((int)$section->batch_id, $coordinatorBatchIds, true);
        }

        return false;
    }

    public function delete(User $user, Section $section): bool
    {
        if ($user->hasRole('Admin')) {
            return true;
        }

        if ($user->hasRole('Chairman')) {
            return empty($user->department_id) 
                || empty($section->batch?->department_id) 
                || (int)$user->department_id === (int)$section->batch?->department_id;
        }

        if ($user->hasRole('Coordinator')) {
            $coordinatorBatchIds = $user->getAssignedBatchIds();
            return in_array((int)$section->batch_id, $coordinatorBatchIds, true);
        }

        return false;
    }

    public function assignAdviser(User $user, Section $section): bool
    {
        if ($user->hasRole('Admin')) {
            return true;
        }

        if ($user->hasRole('Chairman')) {
            return empty($user->department_id) 
                || empty($section->batch?->department_id) 
                || (int)$user->department_id === (int)$section->batch?->department_id;
        }

        if ($user->hasRole('Coordinator')) {
            $coordinatorBatchIds = $user->getAssignedBatchIds();
            return in_array((int)$section->batch_id, $coordinatorBatchIds, true);
        }

        return false;
    }

    public function removeAdviser(User $user, Section $section): bool
    {
        return $this->assignAdviser($user, $section);
    }
}
