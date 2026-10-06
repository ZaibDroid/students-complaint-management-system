<?php

namespace App\Repositories;

use App\Contracts\Repositories\NoticeTargetRepositoryInterface;
use App\Models\NoticeTarget;

class NoticeTargetRepository extends BaseRepository implements NoticeTargetRepositoryInterface
{
    public function __construct(NoticeTarget $model)
    {
        parent::__construct($model);
    }
}
