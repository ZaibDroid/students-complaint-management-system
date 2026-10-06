<?php

namespace App\Repositories;

use App\Contracts\Repositories\BatchRepositoryInterface;
use App\Models\Batch;

class BatchRepository extends BaseRepository implements BatchRepositoryInterface
{
    public function __construct(Batch $model)
    {
        parent::__construct($model);
    }
}
