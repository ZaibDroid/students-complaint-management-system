<?php

namespace App\Repositories\Dashboard;

use App\Models\Application;
use App\Models\Notice;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\Collection;

class AdviserDashboardRepository
{
    public function getMetrics(User $adviser): array
    {
        return Application::where('assigned_to_id', $adviser->id)
            ->select(
                DB::raw('count(*) as assigned_Applications'),
                DB::raw('COALESCE(sum(case when status IN ("submitted", "pending", "under_review") then 1 else 0 end), 0) as pending_review'),
                DB::raw('COALESCE(sum(case when status = "returned" then 1 else 0 end), 0) as returned'),
                DB::raw('COALESCE(sum(case when status = "forwarded" then 1 else 0 end), 0) as forwarded'),
                DB::raw('COALESCE(sum(case when status = "resolved" then 1 else 0 end), 0) as recently_resolved')
            )
            ->first()
            ?->toArray() ?? [];
    }

    public function getUnreadNotificationsCount(User $adviser): int
    {
        return Notification::where('user_id', $adviser->id)->whereNull('read_at')->count();
    }

    public function getRecentApplications(User $adviser): Collection
    {
        return Application::where('assigned_to_id', $adviser->id)->latest()->take(5)->get();
    }

    public function getRecentNotices(): Collection
    {
        return Notice::where('status', 'published')->latest()->take(5)->get();
    }
}
