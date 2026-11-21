<?php

namespace App\Repositories;

use App\Contracts\Repositories\UserRepositoryInterface;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;

class UserRepository extends BaseRepository implements UserRepositoryInterface
{
    public function __construct(User $model)
    {
        parent::__construct($model);
    }

    public function findByEmail(string $email): ?User
    {
        $clean = trim($email);
        return $this->model->where('email', $clean)
            ->orWhereRaw('LOWER(email) = ?', [strtolower($clean)])
            ->orWhere('registration_number', strtoupper($clean))
            ->first();
    }

    public function getStaffMembers(array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->model->with(['department', 'roles', 'assignedSections.batch'])
            ->whereDoesntHave('roles', function ($q) {
                $q->where('name', 'Student');
            });

        if (!empty($filters['role'])) {
            $role = $filters['role'];
            unset($filters['role']);
            $query->role($role);
        }

        if (!empty($filters['batch_id'])) {
            $bId = $filters['batch_id'];
            unset($filters['batch_id']);
            $query->where(function($q) use ($bId) {
                $q->where('batch_id', $bId)
                  ->orWhereHas('assignedSections', function($sq) use ($bId) {
                      $sq->where('batch_id', $bId);
                  });
            });
        }

        if (!empty($filters['section_id'])) {
            $sId = $filters['section_id'];
            unset($filters['section_id']);
            $query->where(function($q) use ($sId) {
                $q->where('section_id', $sId)
                  ->orWhereHas('assignedSections', function($sq) use ($sId) {
                      $sq->where('sections.id', $sId);
                  });
            });
        }

        if (!empty($filters['search'])) {
            $search = trim($filters['search']);
            unset($filters['search']);
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        if (!empty($filters['department_id'])) {
            $query->where('department_id', (int)$filters['department_id']);
            unset($filters['department_id']);
        }

        unset($filters['per_page'], $filters['page']);

        if (!empty($filters) && method_exists($this->model, 'scopeFilter')) {
            $query->filter($filters);
        }

        return $query->paginate($perPage);
    }

    public function getUsers(array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->model->with(['department', 'batch', 'section', 'adviser', 'roles', 'assignedSections.batch']);

        if (!empty($filters['role'])) {
            $role = $filters['role'];
            unset($filters['role']);
            $query->role($role);
        }

        if (!empty($filters['batch_id'])) {
            $bId = $filters['batch_id'];
            unset($filters['batch_id']);
            $query->where(function($q) use ($bId) {
                $q->where('batch_id', $bId)
                  ->orWhereHas('assignedSections', function($sq) use ($bId) {
                      $sq->where('batch_id', $bId);
                  });
            });
        }

        if (!empty($filters['section_id'])) {
            $sId = $filters['section_id'];
            unset($filters['section_id']);
            $query->where(function($q) use ($sId) {
                $q->where('section_id', $sId)
                  ->orWhereHas('assignedSections', function($sq) use ($sId) {
                      $sq->where('sections.id', $sId);
                  });
            });
        }

        if (!empty($filters['search'])) {
            $search = trim($filters['search']);
            unset($filters['search']);
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        if (!empty($filters['department_id'])) {
            $query->where('department_id', (int)$filters['department_id']);
            unset($filters['department_id']);
        }

        unset($filters['per_page'], $filters['page']);

        if (!empty($filters) && method_exists($this->model, 'scopeFilter')) {
            $query->filter($filters);
        }

        return $query->paginate($perPage);
    }

    public function assignSectionsToUser(User $user, array $sectionIds): void
    {
        $cleanIds = [];
        foreach ($sectionIds as $item) {
            if (is_numeric($item)) {
                $cleanIds[] = (int)$item;
            } elseif (is_array($item) && !empty($item['id']) && is_numeric($item['id'])) {
                $cleanIds[] = (int)$item['id'];
            }
        }
        $user->assignedSections()->sync($cleanIds);
    }
}
