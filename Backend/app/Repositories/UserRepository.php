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
        return $this->model->where('email', $email)->first();
    }

    public function getStaffMembers(array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->model->with(['department', 'roles', 'assignedSections'])
            ->whereDoesntHave('roles', function ($q) {
                $q->where('name', 'Student');
            });

        if (!empty($filters['role'])) {
            $role = $filters['role'];
            unset($filters['role']);
            $query->role($role);
        }

        if (!empty($filters) && method_exists($this->model, 'scopeFilter')) {
            $query->filter($filters);
        }

        return $query->paginate($perPage);
    }

    public function getUsers(array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->model->with(['department', 'batch', 'section', 'adviser', 'roles', 'assignedSections']);

        if (!empty($filters['role'])) {
            $role = $filters['role'];
            unset($filters['role']);
            $query->role($role);
        }

        if (!empty($filters) && method_exists($this->model, 'scopeFilter')) {
            $query->filter($filters);
        }

        return $query->paginate($perPage);
    }

    public function assignSectionsToUser(User $user, array $sectionIds): void
    {
        $user->assignedSections()->sync($sectionIds);
    }
}
