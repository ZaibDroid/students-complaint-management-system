<?php

namespace App\Repositories;

use App\Contracts\Repositories\ApplicationRemarkRepositoryInterface;
use App\Models\ApplicationRemark;

class ApplicationRemarkRepository extends BaseRepository implements ApplicationRemarkRepositoryInterface
{
    public function __construct(ApplicationRemark $model)
    {
        parent::__construct($model);
    }
}
