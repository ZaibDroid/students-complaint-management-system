<?php

namespace App\Repositories;

use App\Contracts\Repositories\DepartmentRepositoryInterface;
use App\Models\Department;

class DepartmentRepository extends BaseRepository implements DepartmentRepositoryInterface
{
    public function __construct(Department $model)
    {
        parent::__construct($model);
    }

    public function findByCode(string $code): ?Department
    {
        return $this->model->where('code', $code)->first();
    }
}
