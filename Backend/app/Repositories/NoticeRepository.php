<?php

namespace App\Repositories;

use App\Contracts\Repositories\NoticeRepositoryInterface;
use App\Models\Notice;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;

class NoticeRepository extends BaseRepository implements NoticeRepositoryInterface
{
    public function __construct(Notice $model)
    {
        parent::__construct($model);
    }

    public function getNoticesForUser(User $user, array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->model->with(['sender', 'targets']);

        if ($user->hasRole('Student')) {
            $query->where('status', Notice::STATUS_PUBLISHED)
                  ->whereHas('targets', function ($q) use ($user) {
                $q->where(function ($sub) use ($user) {
                    $sub->where('target_type', 'all_students')
                        ->orWhere(function ($b) use ($user) {
                            $b->where('target_type', 'batch_id')->where('target_value', (string)$user->batch_id);
                        })
                        ->orWhere(function ($s) use ($user) {
                            $s->where('target_type', 'section_id')->where('target_value', (string)$user->section_id);
                        })
                        ->orWhere(function ($y) use ($user) {
                            $y->where('target_type', 'year')->where('target_value', (string)$user->year);
                        })
                        ->orWhere(function ($d) use ($user) {
                            $d->where('target_type', 'department_id')->where('target_value', (string)$user->department_id);
                        })
                        ->orWhere(function ($cr) use ($user) {
                            if ($user->is_cr) {
                                $cr->where('target_type', 'crs_only')->where('target_value', 'true');
                            }
                        });
                });
            });
        }

        // Custom search filters
        if (!empty($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%")
                  ->orWhere('tag', 'like', "%{$search}%");
            });
            unset($filters['search']);
        }

        if (!empty($filters) && method_exists($this->model, 'scopeFilter')) {
            $query->filter($filters);
        }

        return $query->latest('created_at')->paginate($perPage);
    }

    public function lockForUpdate(int $id): ?Notice
    {
        return $this->model->whereKey($id)->lockForUpdate()->first();
    }
}
