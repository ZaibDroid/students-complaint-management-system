<?php

namespace App\Repositories;

use App\Contracts\Repositories\ApplicationRepositoryInterface;
use App\Models\Application;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;

class ApplicationRepository extends BaseRepository implements ApplicationRepositoryInterface
{
    public function __construct(Application $model)
    {
        parent::__construct($model);
    }

    public function getApplicationsForUser(User $user, array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->model->with(['student', 'assignedTo', 'remarks.user', 'timeline.fromUser', 'timeline.toUser']);

        if ($user->hasRole('Student')) {
            $query->where('student_id', $user->id);
        } elseif ($user->hasAnyRole(['Batch Adviser', 'Coordinator', 'Office Staff'])) {
            $query->where(function ($q) use ($user) {
                $q->where('assigned_to_id', $user->id)
                  ->orWhere('student_id', $user->id);
            });
        }
        // Chairman, Dean, Vice Chancellor, Admin can view all Applications.

        // Custom search filter
        if (!empty($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('ticket_number', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
            unset($filters['search']);
        }

        // Apply remaining dynamic filters
        if (!empty($filters) && method_exists($this->model, 'scopeFilter')) {
            $query->filter($filters);
        }

        return $query->latest('created_at')->paginate($perPage);
    }

    public function findByTicketNumber(string $ticketNumber): ?Application
    {
        return $this->model->with(['student', 'assignedTo', 'remarks.user', 'timeline'])->where('ticket_number', $ticketNumber)->first();
    }

    public function lockForUpdate(int $id): ?Application
    {
        return $this->model->whereKey($id)->lockForUpdate()->first();
    }
}
