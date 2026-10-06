<?php

namespace App\Repositories\Dashboard;

use App\Models\Application;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\Collection;

class CoordinatorDashboardRepository
{
    protected function getBaseQuery(int $departmentId)
    {
        return Application::whereHas('student', function ($q) use ($departmentId) {
            $q->where('department_id', $departmentId);
        });
    }

    public function getMetrics(User $coordinator): array
    {
        return $this->getBaseQuery($coordinator->department_id)
            ->select(
                DB::raw('count(*) as total'),
                DB::raw('COALESCE(sum(case when status = "forwarded" then 1 else 0 end), 0) as pending_forwarding')
            )
            ->first()
            ?->toArray() ?? [];
    }

    public function getApplicationsByStatus(User $coordinator): array
    {
        return $this->getBaseQuery($coordinator->department_id)
            ->select('status', DB::raw('count(*) as total'))
            ->groupBy('status')
            ->pluck('total', 'status')
            ->toArray();
    }

    public function getApplicationsByCategory(User $coordinator): array
    {
        return $this->getBaseQuery($coordinator->department_id)
            ->select('category', DB::raw('count(*) as total'))
            ->groupBy('category')
            ->pluck('total', 'category')
            ->toArray();
    }

    public function getAverageResolutionTime(User $coordinator): float
    {
        $resolutionTime = $this->getBaseQuery($coordinator->department_id)
            ->where('status', 'resolved')
            ->whereNotNull('resolved_at')
            ->select(DB::raw('COALESCE(AVG(TIMESTAMPDIFF(HOUR, created_at, resolved_at)), 0) as avg_hours'))
            ->first()?->avg_hours ?? 0;
            
        return (float) $resolutionTime;
    }
}
