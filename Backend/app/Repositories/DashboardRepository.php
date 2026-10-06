<?php

namespace App\Repositories;

use App\Contracts\Repositories\DashboardRepositoryInterface;
use App\Models\Batch;
use App\Models\Application;
use App\Models\Department;
use App\Models\Notice;
use App\Models\Notification;
use App\Models\Section;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class DashboardRepository implements DashboardRepositoryInterface
{
    public function getStudentDashboard(User $student): array
    {
        $metrics = Application::where('student_id', $student->id)
            ->select(
                DB::raw('count(*) as total'),
                DB::raw('COALESCE(sum(case when status = "pending" then 1 else 0 end), 0) as pending'),
                DB::raw('COALESCE(sum(case when status = "under_review" then 1 else 0 end), 0) as under_review'),
                DB::raw('COALESCE(sum(case when status = "in_progress" then 1 else 0 end), 0) as in_progress'),
                DB::raw('COALESCE(sum(case when status = "forwarded" then 1 else 0 end), 0) as forwarded'),
                DB::raw('COALESCE(sum(case when status = "resolved" then 1 else 0 end), 0) as resolved'),
                DB::raw('COALESCE(sum(case when status = "rejected" then 1 else 0 end), 0) as rejected'),
                DB::raw('COALESCE(sum(case when status = "returned" then 1 else 0 end), 0) as returned')
            )
            ->first()
            ?->toArray() ?? [];

        $unreadNotifications = Notification::where('user_id', $student->id)->whereNull('read_at')->count();
        $metrics['unread_notifications'] = $unreadNotifications;

        $recentApplications = Application::where('student_id', $student->id)->select(['id', 'ticket_number', 'title', 'status', 'created_at'])->latest()->take(5)->get();
        
        // Ensure students only see published notices intended for them (simple latest for now, 
        // proper querying would involve checking target morphs, but keeping it simple to just published)
        $recentNotices = Notice::where('status', 'published')->select(['id', 'title', 'created_at'])->latest()->take(5)->get();

        return [
            'metrics' => $metrics,
            'recent_Applications' => $recentApplications,
            'recent_notices' => $recentNotices,
        ];
    }

    public function getAdviserDashboard(User $adviser): array
    {
        $metrics = Application::where('assigned_to_id', $adviser->id)
            ->select(
                DB::raw('count(*) as assigned_Applications'),
                DB::raw('COALESCE(sum(case when status IN ("submitted", "pending", "under_review") then 1 else 0 end), 0) as pending_review'),
                DB::raw('COALESCE(sum(case when status = "returned" then 1 else 0 end), 0) as returned'),
                DB::raw('COALESCE(sum(case when status = "forwarded" then 1 else 0 end), 0) as forwarded'),
                DB::raw('COALESCE(sum(case when status = "resolved" then 1 else 0 end), 0) as recently_resolved')
            )
            ->first()
            ?->toArray() ?? [];

        $unreadNotifications = Notification::where('user_id', $adviser->id)->whereNull('read_at')->count();
        $metrics['unread_notifications'] = $unreadNotifications;

        $recentApplications = Application::where('assigned_to_id', $adviser->id)->select(['id', 'ticket_number', 'title', 'status', 'created_at'])->latest()->take(5)->get();
        $recentNotices = Notice::where('status', 'published')->select(['id', 'title', 'created_at'])->latest()->take(5)->get();

        return [
            'metrics' => $metrics,
            'recent_Applications' => $recentApplications,
            'recent_notices' => $recentNotices,
        ];
    }

    public function getCoordinatorDashboard(User $coordinator): array
    {
        $departmentId = $coordinator->department_id;

        // Base query scoped to the coordinator's department
        $baseQuery = Application::whereHas('student', function ($q) use ($departmentId) {
            if ($departmentId) {
                $q->where('department_id', $departmentId);
            }
        });

        $byStatus = (clone $baseQuery)
            ->select('status', DB::raw('count(*) as total'))
            ->groupBy('status')
            ->pluck('total', 'status');

        $byCategory = (clone $baseQuery)
            ->select('category', DB::raw('count(*) as total'))
            ->groupBy('category')
            ->pluck('total', 'category');

        $resolutionTime = (clone $baseQuery)
            ->where('status', 'resolved')
            ->whereNotNull('resolved_at')
            ->select(DB::raw('COALESCE(AVG(TIMESTAMPDIFF(HOUR, created_at, resolved_at)), 0) as avg_hours'))
            ->first()->avg_hours ?? 0;

        $pendingForwarding = (clone $baseQuery)
            ->where('status', 'forwarded')
            ->count();

        $recentActivity = (clone $baseQuery)->select(['id', 'ticket_number', 'title', 'status', 'created_at'])->latest()->take(10)->get();

        return [
            'by_status' => $byStatus,
            'by_category' => $byCategory,
            'average_resolution_time' => (float) $resolutionTime,
            'metrics' => [
                'pending_forwarding' => $pendingForwarding,
            ],
            'recent_activity' => $recentActivity,
        ];
    }

    public function getChairmanDashboard(): array
    {
        $metrics = Application::select(
                DB::raw('count(*) as total_Applications'),
                DB::raw('COALESCE(sum(case when status = "resolved" then 1 else 0 end), 0) as total_resolved')
            )
            ->first()
            ?->toArray() ?? [];

        $metrics['total_students'] = User::role('Student')->count();
        $metrics['total_staff'] = User::whereDoesntHave('roles', function ($q) { $q->where('name', 'Student'); })->count();
        $metrics['active_notices'] = Notice::where('status', 'published')->count();
        
        $metrics['resolution_rate'] = $metrics['total_Applications'] > 0 
            ? round(($metrics['total_resolved'] / $metrics['total_Applications']) * 100, 2) 
            : 0;

        $byStatus = Application::select('status', DB::raw('count(*) as total'))
            ->groupBy('status')
            ->pluck('total', 'status');

        $byPriority = Application::select('priority', DB::raw('count(*) as total'))
            ->groupBy('priority')
            ->pluck('total', 'priority');

        $byCategory = Application::select('category', DB::raw('count(*) as total'))
            ->groupBy('category')
            ->pluck('total', 'category');

        $monthlyTrends = Application::where('created_at', '>=', now()->subMonths(6))
            ->select(DB::raw('DATE_FORMAT(created_at, "%Y-%m") as month'), DB::raw('count(*) as total'))
            ->groupBy('month')
            ->orderBy('month', 'ASC')
            ->get();

        $staffPerformance = User::whereDoesntHave('roles', function ($q) { $q->where('name', 'Student'); })
            ->withCount([
                'ApplicationsAssigned as total_assigned',
                'ApplicationsAssigned as total_resolved' => function ($q) {
                    $q->where('status', 'resolved');
                }
            ])->orderByDesc('total_resolved')->take(10)->get();

        return [
            'metrics' => $metrics,
            'by_status' => $byStatus,
            'by_priority' => $byPriority,
            'by_category' => $byCategory,
            'monthly_trends' => $monthlyTrends,
            'staff_performance' => $staffPerformance,
        ];
    }

    public function getAdminDashboard(): array
    {
        $metrics = [];
        $metrics['users'] = User::count();
        $metrics['departments'] = Department::count();
        $metrics['batches'] = Batch::count();
        $metrics['sections'] = Section::count();
        $metrics['applications'] = Application::count();
        $metrics['notices'] = Notice::count();
        $metrics['notifications'] = Notification::count();

        $registrationTrend = User::select(DB::raw('DATE(created_at) as date'), DB::raw('count(*) as total'))
            ->where('created_at', '>=', now()->subDays(30))
            ->groupBy('date')
            ->orderBy('date', 'ASC')
            ->get();

        $applicationTrend = Application::select(DB::raw('DATE(created_at) as date'), DB::raw('count(*) as total'))
            ->where('created_at', '>=', now()->subDays(30))
            ->groupBy('date')
            ->orderBy('date', 'ASC')
            ->get();

        return [
            'metrics' => $metrics,
            'registration_trend' => $registrationTrend,
            'Application_trend' => $applicationTrend,
        ];
    }
}
