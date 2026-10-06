<?php

namespace App\Policies;

use App\Models\Application;
use App\Models\User;

class ApplicationPolicy
{
    public function before(User $user, string $ability): ?bool
    {
        if ($user->hasRole('Admin')) {
            return true;
        }

        return null;
    }

    public function viewAny(User $user): bool
    {
        return true;
    }

    public function view(User $user, Application $application): bool
    {
        if ($user->hasAnyRole(['Chairman', 'Dean', 'Vice Chancellor'])) {
            return true;
        }

        return $application->student_id === $user->id || $application->assigned_to_id === $user->id;
    }

    public function create(User $user): bool
    {
        return $user->hasRole('Student');
    }

    public function update(User $user, Application $application): bool
    {
        if ($application->student_id === $user->id && in_array($application->status, [Application::STATUS_PENDING, Application::STATUS_RETURNED])) {
            return true;
        }

        return $user->hasAnyRole(['Batch Adviser', 'Coordinator', 'Chairman', 'Office Staff']);
    }

    public function updateStatus(User $user, Application $application): bool
    {
        if ($user->hasAnyRole(['Chairman', 'Dean'])) {
            return true;
        }

        return $application->assigned_to_id === $user->id || ($application->student_id === $user->id && $application->status === Application::STATUS_RESOLVED);
    }

    public function forward(User $user, Application $application): bool
    {
        return $this->updateStatus($user, $application);
    }

    public function resolve(User $user, Application $application): bool
    {
        return $this->updateStatus($user, $application);
    }

    public function delete(User $user, Application $application): bool
    {
        return $application->student_id === $user->id && $application->status === Application::STATUS_PENDING;
    }

    public function addRemark(User $user, Application $application): bool
    {
        return $this->view($user, $application);
    }
}
