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
        $query = $this->model->with(['sender', 'attachments']);

        if ($user->hasRole('Student')) {
            $query->where('status', Notice::STATUS_PUBLISHED)
                  ->where(function ($q) use ($user) {
                      $q->where(function ($sub) use ($user) {
                          $sub->whereNull('department_id')
                              ->orWhere('department_id', $user->department_id);
                      })
                      ->where(function ($sub) use ($user) {
                          $sub->whereNull('target_batch_id')
                              ->orWhere('target_batch_id', $user->batch_id);
                      })
                      ->where(function ($sub) use ($user) {
                          $sub->whereNull('target_section_id')
                              ->orWhere('target_section_id', $user->section_id);
                      })
                      ->where(function ($sub) use ($user) {
                          $isCr = $user->is_cr || $user->hasAnyRole(['CR', 'Class Representative']);
                          $sub->whereNull('target_role')
                              ->orWhere('target_role', '!=', 'CR');
                          if ($isCr) {
                              $sub->orWhere('target_role', 'CR');
                          }
                      });
                  });
        } elseif (!$user->hasRole('Admin')) {
            if ($user->department_id) {
                $query->where(function ($q) use ($user) {
                    $q->whereNull('department_id')
                      ->orWhere('department_id', $user->department_id);
                });
            } else {
                $query->whereNull('department_id');
            }
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
