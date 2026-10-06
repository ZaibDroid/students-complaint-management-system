<?php

namespace App\Services;

use App\Contracts\Repositories\DepartmentRepositoryInterface;
use App\Contracts\Services\DepartmentServiceInterface;

class DepartmentService extends BaseService implements DepartmentServiceInterface
{
    public function __construct(DepartmentRepositoryInterface $repository)
    {
        parent::__construct($repository);
    }
}
