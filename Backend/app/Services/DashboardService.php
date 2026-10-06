<?php

namespace App\Services;

use App\Contracts\Services\DashboardServiceInterface;
use App\DTOs\DashboardDTO;
use App\Factories\DashboardFactory;
use App\Models\User;

class DashboardService implements DashboardServiceInterface
{
    protected DashboardFactory $dashboardFactory;
    protected DashboardCacheService $cacheService;

    public function __construct(DashboardFactory $dashboardFactory, DashboardCacheService $cacheService)
    {
        $this->dashboardFactory = $dashboardFactory;
        $this->cacheService = $cacheService;
    }

    public function getDashboardForUser(User $user): \App\DTOs\DashboardDTO
    {
        // Use cache service to remember the DTO for this role
        return $this->cacheService->remember($user, function () use ($user) {
            $builder = $this->dashboardFactory->make($user);
            return $builder->build($user);
        });
    }

    // Retained for any global chart endpoints, though mostly superseded by Dashboard roles
    public function getChartsData(string $type, array $filters = []): array
    {
        return match ($type) {
            'Applications-per-month' => [
                'chart' => 'Applications Per Month',
                'data' => \App\Models\Application::select(\Illuminate\Support\Facades\DB::raw("DATE_FORMAT(created_at, '%Y-%m') as month"), \Illuminate\Support\Facades\DB::raw('count(*) as count'))
                    ->groupBy('month')
                    ->orderBy('month', 'ASC')
                    ->get()
            ],
            'Applications-by-status' => [
                'chart' => 'Applications By Status',
                'data' => \App\Models\Application::select('status', \Illuminate\Support\Facades\DB::raw('count(*) as count'))
                    ->groupBy('status')
                    ->get()
            ],
            'Applications-by-category' => [
                'chart' => 'Applications By Category',
                'data' => \App\Models\Application::select('category', \Illuminate\Support\Facades\DB::raw('count(*) as count'))
                    ->groupBy('category')
                    ->get()
            ],
            'user-registration-trend' => [
                'chart' => 'User Registration Trend',
                'data' => \App\Models\User::select(\Illuminate\Support\Facades\DB::raw("DATE_FORMAT(created_at, '%Y-%m-%d') as date"), \Illuminate\Support\Facades\DB::raw('count(*) as count'))
                    ->where('created_at', '>=', now()->subDays(30))
                    ->groupBy('date')
                    ->orderBy('date', 'ASC')
                    ->get()
            ],
            default => [
                'chart' => 'Applications By Status',
                'data' => \App\Models\Application::select('status', \Illuminate\Support\Facades\DB::raw('count(*) as count'))->groupBy('status')->get()
            ]
        };
    }
}
