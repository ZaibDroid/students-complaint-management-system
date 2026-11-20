<?php

namespace App\Policies;

use App\Models\Batch;
use App\Models\User;

class BatchPolicy
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

    public function view(?User $user, ?Batch $batch = null): bool
    {
        return true;
    }

    public function create(User $user): bool
    {
        return $user->hasAnyRole(['Admin', 'Chairman']);
    }

    public function update(User $user, Batch $batch): bool
    {
        if ($user->hasRole('Admin')) {
            return true;
        }

        if ($user->hasRole('Chairman')) {
            return empty($user->department_id) 
                || empty($batch->department_id) 
                || (int)$user->department_id === (int)$batch->department_id;
        }

        if ($user->hasRole('Coordinator')) {
            $coordinatorBatchIds = $user->getAssignedBatchIds();
            return in_array((int)$batch->id, $coordinatorBatchIds, true);
        }

        return false;
    }

    public function delete(User $user, Batch $batch): bool
    {
        if ($user->hasRole('Admin')) {
            return true;
        }

        if ($user->hasRole('Chairman')) {
            return empty($user->department_id) 
                || empty($batch->department_id) 
                || (int)$user->department_id === (int)$batch->department_id;
        }

        // Coordinators cannot delete batches under institutional governance rules
        return false;
    }
}
