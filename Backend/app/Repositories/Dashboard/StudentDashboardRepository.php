<?php

namespace App\Repositories\Dashboard;

use App\Models\Application;
use App\Models\Notice;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\Collection;

class StudentDashboardRepository
{
    public function getMetrics(User $student): array
    {
        return Application::where('student_id', $student->id)
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
    }

    public function getUnreadNotificationsCount(User $student): int
    {
        return Notification::where('user_id', $student->id)->whereNull('read_at')->count();
    }

    public function getRecentApplications(User $student): Collection
    {
        return Application::where('student_id', $student->id)->latest()->take(5)->get();
    }

    public function getRecentNotices(User $student): Collection
    {
        return Notice::where('status', 'published')->latest()->take(5)->get();
    }
}
