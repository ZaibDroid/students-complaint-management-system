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
        if ($user->hasRole('Admin') || $user->hasAnyRole(['Dean', 'Vice Chancellor'])) {
            return true;
        }

        // Student can only view their own complaint
        if ($user->hasRole('Student')) {
            return (int)$application->student_id === (int)$user->id;
        }

        // Coordinator: strictly isolated to complaints belonging to their assigned batch
        if ($user->hasRole('Coordinator')) {
            return $this->isCoordinatorAuthorized($user, $application);
        }

        // Chairman and Office Staff are scoped to their department or complaints assigned to them
        if ($user->hasAnyRole(['Chairman', 'Office Staff'])) {
            if ((int)$application->assigned_to_id === (int)$user->id) {
                return true;
            }
            if (empty($user->department_id) || empty($application->department_id)) {
                return false;
            }
            return (int)$application->department_id === (int)$user->department_id;
        }

        // Batch Adviser: assigned to them, or submitted by student in assigned section/batch
        if ($user->hasAnyRole(['Batch Adviser', 'Batch Advisor'])) {
            if ((int)$application->assigned_to_id === (int)$user->id || (int)$application->student_id === (int)$user->id) {
                return true;
            }

            $student = $application->student;
            if ($student) {
                if ($user->section_id && (int)$student->section_id === (int)$user->section_id) {
                    return true;
                }
                if ($user->batch_id && (int)$student->batch_id === (int)$user->batch_id) {
                    return true;
                }
                if ($user->assignedSections()->where('sections.id', $student->section_id)->exists()) {
                    return true;
                }
            }

            return false;
        }

        return (int)$application->student_id === (int)$user->id || (int)$application->assigned_to_id === (int)$user->id;
    }

    public function create(User $user): bool
    {
        return $user->hasRole('Student') || $user->hasRole('CR');
    }

    public function update(User $user, Application $application): bool
    {
        if ($user->hasRole('Admin')) {
            return true;
        }

        // Student can update their own application only when pending or returned
        if ((int)$application->student_id === (int)$user->id) {
            return in_array($application->status, [Application::STATUS_PENDING, Application::STATUS_RETURNED]);
        }

        // Coordinator: strictly isolated to complaints belonging to their assigned batch
        if ($user->hasRole('Coordinator')) {
            return $this->isCoordinatorAuthorized($user, $application);
        }

        // Chairman, Office Staff: must match department
        if ($user->hasAnyRole(['Chairman', 'Office Staff'])) {
            return !empty($user->department_id) 
                && !empty($application->department_id) 
                && (int)$application->department_id === (int)$user->department_id;
        }

        // Batch Adviser: must be assigned to them OR student belongs to their assigned section/batch
        if ($user->hasAnyRole(['Batch Adviser', 'Batch Advisor'])) {
            if ((int)$application->assigned_to_id === (int)$user->id) {
                return true;
            }

            $student = $application->student;
            if ($student) {
                if ($user->section_id && (int)$student->section_id === (int)$user->section_id) {
                    return true;
                }
                if ($user->batch_id && (int)$student->batch_id === (int)$user->batch_id) {
                    return true;
                }
                if ($user->assignedSections()->where('sections.id', $student->section_id)->exists()) {
                    return true;
                }
            }
        }

        return false;
    }

    public function updateStatus(User $user, Application $application): bool
    {
        if ($user->hasRole('Admin') || $user->hasAnyRole(['Dean', 'Vice Chancellor'])) {
            return true;
        }

        // Coordinator: can modify status (forward, resolve, reject, return) ONLY within their assigned batch
        if ($user->hasRole('Coordinator')) {
            return $this->isCoordinatorAuthorized($user, $application);
        }

        // Chairman: complaints assigned to them or in their department
        if ($user->hasRole('Chairman')) {
            if ((int)$application->assigned_to_id === (int)$user->id) {
                return true;
            }
            if (empty($user->department_id) || empty($application->department_id)) {
                return false;
            }
            return (int)$application->department_id === (int)$user->department_id;
        }

        // Batch Adviser: must be currently assigned to them AND authorized for their assigned sections
        if ($user->hasAnyRole(['Batch Adviser', 'Batch Advisor'])) {
            return (int)$application->assigned_to_id === (int)$user->id
                && $application->isAdviserAuthorized($user);
        }

        // Student: only self, and only if resolved (e.g. feedback/acknowledgement)
        if ((int)$application->student_id === (int)$user->id && $application->status === Application::STATUS_RESOLVED) {
            return true;
        }

        return false;
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

    public function reject(User $user, Application $application): bool
    {
        return $this->updateStatus($user, $application);
    }

    public function return(User $user, Application $application): bool
    {
        return $this->updateStatus($user, $application);
    }

    public function addRemark(User $user, Application $application): bool
    {
        return $this->view($user, $application);
    }

    /**
     * Determine if a coordinator is authorized for the given application's batch.
     */
    protected function isCoordinatorAuthorized(User $user, Application $application): bool
    {
        $student = $application->student;
        if (!$student || empty($student->batch_id)) {
            return false;
        }

        $coordinatorBatchIds = $user->getAssignedBatchIds();
        if (empty($coordinatorBatchIds) || !in_array((int)$student->batch_id, $coordinatorBatchIds, true)) {
            return false;
        }

        if (!empty($user->department_id) && !empty($application->department_id) && (int)$application->department_id !== (int)$user->department_id) {
            return false;
        }

        // Coordinator can only access complaints that are actually assigned or routed to them
        if ((int)$application->assigned_to_id === (int)$user->id) {
            return true;
        }

        return $application->timeline()
            ->where(function ($q) use ($user) {
                $q->where('to_user_id', $user->id)
                  ->orWhere('from_user_id', $user->id);
            })
            ->exists();
    }
}
