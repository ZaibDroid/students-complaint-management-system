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
        } elseif ($user->hasRole('Batch Adviser')) {
            $assignedSectionIds = $user->assignedSections()->pluck('sections.id')->toArray();
            $query->where(function ($q) use ($user, $assignedSectionIds) {
                $q->where('assigned_to_id', $user->id)
                  ->orWhere('student_id', $user->id)
                  ->orWhereHas('timeline', function ($tq) use ($user) {
                      $tq->where('from_user_id', $user->id)->orWhere('to_user_id', $user->id);
                  });
                if (!empty($assignedSectionIds)) {
                    $q->orWhereHas('student', function ($sq) use ($assignedSectionIds) {
                        $sq->whereIn('section_id', $assignedSectionIds);
                    });
                }
            });
        } elseif ($user->hasAnyRole(['Coordinator', 'Office Staff'])) {
            $query->where(function ($q) use ($user) {
                $q->where('assigned_to_id', $user->id)
                  ->orWhere('student_id', $user->id)
                  ->orWhereHas('timeline', function ($tq) use ($user) {
                      $tq->where('from_user_id', $user->id)->orWhere('to_user_id', $user->id);
                  });
                if ($user->department_id) {
                    $q->orWhereHas('student', function ($sq) use ($user) {
                        $sq->where('department_id', $user->department_id);
                    });
                }
            });
        } elseif (!$user->hasAnyRole(['Chairman', 'Dean', 'Vice Chancellor', 'Admin'])) {
            // Any other role created in the future
            $query->where(function ($q) use ($user) {
                $q->where('assigned_to_id', $user->id)
                  ->orWhere('student_id', $user->id)
                  ->orWhereHas('timeline', function ($tq) use ($user) {
                      $tq->where('from_user_id', $user->id)->orWhere('to_user_id', $user->id);
                  });
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
