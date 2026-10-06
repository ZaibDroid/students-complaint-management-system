<?php

namespace App\Repositories;

use App\Contracts\Repositories\ReportRepositoryInterface;
use App\Models\Application;
use App\Models\Notice;
use App\Models\User;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class ReportRepository implements ReportRepositoryInterface
{
    public function getApplicationReport(array $filters): Collection
    {
        $query = Application::with(['student', 'assignedTo']);

        if (!empty($filters['start_date'])) {
            $query->whereDate('created_at', '>=', $filters['start_date']);
        }
        if (!empty($filters['end_date'])) {
            $query->whereDate('created_at', '<=', $filters['end_date']);
        }
        if (!empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }
        if (!empty($filters['priority'])) {
            $query->where('priority', $filters['priority']);
        }
        if (!empty($filters['category'])) {
            $query->where('category', $filters['category']);
        }

        return $query->get();
    }

    public function getUserReport(array $filters): Collection
    {
        $query = User::with(['department', 'batch', 'section', 'roles']);

        if (!empty($filters['role'])) {
            $query->role($filters['role']);
        }
        if (!empty($filters['batch_id'])) {
            $query->where('batch_id', $filters['batch_id']);
        }
        if (!empty($filters['section_id'])) {
            $query->where('section_id', $filters['section_id']);
        }
        if (!empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        return $query->get();
    }

    public function getStaffPerformanceReport(array $filters): Collection
    {
        $query = User::whereDoesntHave('roles', function ($q) {
            $q->where('name', 'Student');
        })->withCount([
            'ApplicationsAssigned as total_assigned',
            'ApplicationsAssigned as total_resolved' => function ($q) {
                $q->where('status', 'resolved');
            },
            'ApplicationsAssigned as total_pending' => function ($q) {
                $q->whereIn('status', ['submitted', 'pending', 'under_review', 'in_progress']);
            }
        ]);

        return $query->get();
    }

    public function getNoticeReport(array $filters): Collection
    {
        $query = Notice::with(['sender', 'targets']);

        if (!empty($filters['start_date'])) {
            $query->whereDate('created_at', '>=', $filters['start_date']);
        }
        if (!empty($filters['end_date'])) {
            $query->whereDate('created_at', '<=', $filters['end_date']);
        }
        if (!empty($filters['tag'])) {
            $query->where('tag', $filters['tag']);
        }

        return $query->get();
    }
}
