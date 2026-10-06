<?php

namespace App\Services;

use App\Contracts\Repositories\BatchRepositoryInterface;
use App\Contracts\Services\BatchServiceInterface;

class BatchService extends BaseService implements BatchServiceInterface
{
    public function __construct(BatchRepositoryInterface $repository)
    {
        parent::__construct($repository);
    }
}
