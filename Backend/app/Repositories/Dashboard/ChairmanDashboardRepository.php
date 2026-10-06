<?php

namespace App\Repositories\Dashboard;

use App\Models\Application;
use App\Models\Notice;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\Collection;

class ChairmanDashboardRepository
{
    protected function getBaseQuery(int $departmentId)
    {
        return Application::whereHas('student', function ($q) use ($departmentId) {
            $q->where('department_id', $departmentId);
        });
    }

    public function getMetrics(User $chairman): array
    {
        $metrics = $this->getBaseQuery($chairman->department_id)
            ->select(
                DB::raw('count(*) as total_Applications'),
                DB::raw('COALESCE(sum(case when status = "resolved" then 1 else 0 end), 0) as total_resolved')
            )
            ->first()
            ?->toArray() ?? [];

        $metrics['total_students'] = User::role('Student')->where('department_id', $chairman->department_id)->count();
        $metrics['total_staff'] = User::where('department_id', $chairman->department_id)
            ->whereDoesntHave('roles', function ($q) { $q->where('name', 'Student'); })
            ->count();
        
        $metrics['active_notices'] = Notice::where('status', 'published')->count();
        
        $metrics['resolution_rate'] = $metrics['total_Applications'] > 0 
            ? round(($metrics['total_resolved'] / $metrics['total_Applications']) * 100, 2) 
            : 0;

        return $metrics;
    }

    public function getApplicationsByStatus(User $chairman): array
    {
        return $this->getBaseQuery($chairman->department_id)
            ->select('status', DB::raw('count(*) as total'))
            ->groupBy('status')
            ->pluck('total', 'status')
            ->toArray();
    }

    public function getApplicationsByPriority(User $chairman): array
    {
        return $this->getBaseQuery($chairman->department_id)
            ->select('priority', DB::raw('count(*) as total'))
            ->groupBy('priority')
            ->pluck('total', 'priority')
            ->toArray();
    }

    public function getApplicationsByCategory(User $chairman): array
    {
        return $this->getBaseQuery($chairman->department_id)
            ->select('category', DB::raw('count(*) as total'))
            ->groupBy('category')
            ->pluck('total', 'category')
            ->toArray();
    }

    public function getMonthlyTrends(User $chairman, int $lastMonths = 6): array
    {
        return $this->getBaseQuery($chairman->department_id)
            ->where('created_at', '>=', now()->subMonths($lastMonths))
            ->select(DB::raw('DATE_FORMAT(created_at, "%Y-%m") as month'), DB::raw('count(*) as total'))
            ->groupBy('month')
            ->orderBy('month', 'ASC')
            ->get()
            ->toArray();
    }

    public function getStaffPerformance(User $chairman): Collection
    {
        return User::where('department_id', $chairman->department_id)
            ->whereDoesntHave('roles', function ($q) { $q->where('name', 'Student'); })
            ->withCount([
                'ApplicationsAssigned as total_assigned',
                'ApplicationsAssigned as total_resolved' => function ($q) {
                    $q->where('status', 'resolved');
                }
            ])
            ->orderByDesc('total_resolved')
            ->take(10)
            ->get();
    }
}
