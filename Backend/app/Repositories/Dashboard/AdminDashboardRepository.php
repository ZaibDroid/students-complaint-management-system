<?php

namespace App\Repositories\Dashboard;

use App\Models\Batch;
use App\Models\Application;
use App\Models\Department;
use App\Models\Notice;
use App\Models\Notification;
use App\Models\Section;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class AdminDashboardRepository
{
    public function getSystemStatistics(): array
    {
        return [
            'users' => User::count(),
            'departments' => Department::count(),
            'batches' => Batch::count(),
            'sections' => Section::count(),
            'applications' => Application::count(),
            'notices' => Notice::count(),
            'notifications' => Notification::count(),
        ];
    }

    public function getRegistrationTrends(int $lastDays = 30): array
    {
        return User::select(DB::raw('DATE(created_at) as date'), DB::raw('count(*) as total'))
            ->where('created_at', '>=', now()->subDays($lastDays))
            ->groupBy('date')
            ->orderBy('date', 'ASC')
            ->get()
            ->toArray();
    }

    public function getApplicationTrends(int $lastDays = 30): array
    {
        return Application::select(DB::raw('DATE(created_at) as date'), DB::raw('count(*) as total'))
            ->where('created_at', '>=', now()->subDays($lastDays))
            ->groupBy('date')
            ->orderBy('date', 'ASC')
            ->get()
            ->toArray();
    }
}
