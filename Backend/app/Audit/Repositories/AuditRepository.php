<?php

namespace App\Audit\Repositories;

use App\Models\AuditLog;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class AuditRepository
{
    /**
     * Get the latest audit logs.
     */
    public function latest(int $limit = 10): Collection
    {
        return AuditLog::with(['user', 'model'])
            ->latest('created_at')
            ->take($limit)
            ->get();
    }

    /**
     * Get audit logs for a specific user.
     */
    public function forUser(int $userId, int $perPage = 20): LengthAwarePaginator
    {
        return AuditLog::with('model')
            ->where('user_id', $userId)
            ->latest('created_at')
            ->paginate($perPage);
    }

    /**
     * Get audit logs for a specific model.
     */
    public function forModel(string $modelType, int $modelId, int $perPage = 20): LengthAwarePaginator
    {
        return AuditLog::with('user')
            ->where('model_type', $modelType)
            ->where('model_id', $modelId)
            ->latest('created_at')
            ->paginate($perPage);
    }

    /**
     * Paginate search/filtered audit logs.
     */
    public function search(array $filters = [], int $perPage = 50): LengthAwarePaginator
    {
        $query = AuditLog::with(['user', 'model'])->latest('created_at');

        if (!empty($filters['action'])) {
            $query->where('action', $filters['action']);
        }

        if (!empty($filters['user_id'])) {
            $query->where('user_id', $filters['user_id']);
        }

        if (!empty($filters['from_date'])) {
            $query->whereDate('created_at', '>=', $filters['from_date']);
        }

        if (!empty($filters['to_date'])) {
            $query->whereDate('created_at', '<=', $filters['to_date']);
        }

        return $query->paginate($perPage);
    }
}
