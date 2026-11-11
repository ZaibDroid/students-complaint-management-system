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
        $query = $this->model->with([
            'department',
            'attachments',
            'student.batch',
            'student.section',
            'assignedTo',
            'remarks.user',
            'timeline.fromUser',
            'timeline.toUser',
        ]);

        if ($user->hasRole('Student')) {
            $query->where('student_id', $user->id);
        } elseif ($user->hasAnyRole(['Batch Adviser', 'Batch Advisor'])) {
            $assignedSectionIds = $user->assignedSections()->pluck('sections.id')->toArray();
            if ($user->section_id && !in_array($user->section_id, $assignedSectionIds)) {
                $assignedSectionIds[] = $user->section_id;
            }

            $query->where(function ($q) use ($user, $assignedSectionIds) {
                $q->where('assigned_to_id', $user->id)
                  ->orWhere('student_id', $user->id);

                if (!empty($assignedSectionIds) || !empty($user->batch_id)) {
                    $q->orWhereHas('student', function ($sq) use ($user, $assignedSectionIds) {
                        $sq->where(function ($sub) use ($user, $assignedSectionIds) {
                            if (!empty($assignedSectionIds)) {
                                $sub->whereIn('section_id', $assignedSectionIds);
                            }
                            if (!empty($user->batch_id)) {
                                $sub->orWhere('batch_id', $user->batch_id);
                            }
                        });
                    });
                }
            });
        } elseif ($user->hasAnyRole(['Coordinator', 'Chairman'])) {
            if ($user->department_id) {
                $query->where('department_id', $user->department_id);
            } else {
                $query->whereRaw('1 = 0');
            }
        } elseif ($user->hasRole('Office Staff')) {
            if ($user->department_id) {
                $query->where('department_id', $user->department_id);
            } else {
                $query->whereRaw('1 = 0');
            }
        }
        // Dean, Vice Chancellor, Admin can view across all departments.

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
