<?php

namespace App\Contracts\Repositories;

use App\Models\Department;

interface DepartmentRepositoryInterface extends BaseRepositoryInterface
{
    public function findByCode(string $code): ?Department;
}
