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
        if ($user->hasAnyRole(['Chairman', 'Dean', 'Vice Chancellor', 'Admin', 'Coordinator'])) {
            return true;
        }

        if ($application->student_id === $user->id || $application->assigned_to_id === $user->id) {
            return true;
        }

        if ($user->hasRole('Batch Adviser')) {
            if ($application->student && ($application->student->adviser_id === $user->id || ($application->student->section_id && $user->assignedSections()->where('sections.id', $application->student->section_id)->exists()))) {
                return true;
            }
        }

        return $application->timeline()->where(function ($q) use ($user) {
            $q->where('from_user_id', $user->id)->orWhere('to_user_id', $user->id);
        })->exists();
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

        return !$user->hasRole('Student');
    }

    public function updateStatus(User $user, Application $application): bool
    {
        if ($user->hasAnyRole(['Chairman', 'Dean', 'Vice Chancellor', 'Coordinator'])) {
            return true;
        }

        if ($application->assigned_to_id === $user->id) {
            return true;
        }

        if ($user->hasRole('Batch Adviser')) {
            if ($application->student && ($application->student->adviser_id === $user->id || ($application->student->section_id && $user->assignedSections()->where('sections.id', $application->student->section_id)->exists()))) {
                return true;
            }
        }

        if (!$user->hasRole('Student') && $application->assigned_to_id === $user->id) {
            return true;
        }

        return ($application->student_id === $user->id && $application->status === Application::STATUS_RESOLVED);
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
