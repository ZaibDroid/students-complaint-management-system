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

        // Chairman, Coordinator, Office Staff are strictly scoped to their own department
        if ($user->hasAnyRole(['Chairman', 'Coordinator', 'Office Staff'])) {
            return !empty($user->department_id) 
                && !empty($application->department_id) 
                && (int)$application->department_id === (int)$user->department_id;
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

        // Chairman, Coordinator, Office Staff: must match department
        if ($user->hasAnyRole(['Chairman', 'Coordinator', 'Office Staff'])) {
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

        // Chairman and Coordinator: strictly enforced department boundary
        if ($user->hasAnyRole(['Chairman', 'Coordinator'])) {
            return !empty($user->department_id) 
                && !empty($application->department_id) 
                && (int)$application->department_id === (int)$user->department_id;
        }

        // Batch Adviser: must be currently assigned to them
        if ($user->hasAnyRole(['Batch Adviser', 'Batch Advisor'])) {
            return (int)$application->assigned_to_id === (int)$user->id;
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

    public function addRemark(User $user, Application $application): bool
    {
        return $this->view($user, $application);
    }
}
