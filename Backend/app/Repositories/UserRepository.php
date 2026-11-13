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
        return $this->model->where('email', $email)
            ->orWhere('registration_number', strtoupper(trim($email)))
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
