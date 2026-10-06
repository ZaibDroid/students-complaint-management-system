<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Cache;

class DashboardCacheService
{
    /**
     * Remember a dashboard DTO for a specific user role/context.
     */
    public function remember(User $user, callable $callback)
    {
        $key = $this->generateKey($user);
        $ttl = config('cache.dashboard_ttl', 60);
        return Cache::remember($key, $ttl, $callback);
    }

    /**
     * Generate the cache key for a specific user based on their role.
     */
    public function generateKey(User $user): string
    {
        if ($user->hasRole('Student')) {
            return "dashboard:user:{$user->id}";
        }
        
        if ($user->hasRole('Batch Adviser')) {
            return "dashboard:adviser:{$user->id}";
        }
        
        if ($user->hasRole('Coordinator')) {
            return "dashboard:coordinator:department_{$user->department_id}";
        }
        
        if ($user->hasRole('Chairman') || $user->hasRole('Dean')) {
            return "dashboard:chairman:department_{$user->department_id}";
        }
        
        if ($user->hasRole('Admin')) {
            return "dashboard:admin";
        }

        return "dashboard:user:{$user->id}";
    }

    /**
     * Forget a specific cache key.
     */
    public function forget(string $key): void
    {
        Cache::forget($key);
    }

    /**
     * Helper to forget student cache.
     */
    public function forgetStudent(int $userId): void
    {
        $this->forget("dashboard:user:{$userId}");
    }

    /**
     * Helper to forget adviser cache.
     */
    public function forgetAdviser(int $userId): void
    {
        $this->forget("dashboard:adviser:{$userId}");
    }

    /**
     * Helper to forget coordinator cache for a department.
     */
    public function forgetCoordinator(int $departmentId): void
    {
        $this->forget("dashboard:coordinator:department_{$departmentId}");
    }

    /**
     * Helper to forget chairman cache for a department.
     */
    public function forgetChairman(int $departmentId): void
    {
        $this->forget("dashboard:chairman:department_{$departmentId}");
    }

    /**
     * Helper to forget admin cache.
     */
    public function forgetAdmin(): void
    {
        $this->forget("dashboard:admin");
    }
}
