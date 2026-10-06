<?php

namespace App\Repositories;

use App\Contracts\Repositories\ApplicationTimelineRepositoryInterface;
use App\Models\ApplicationTimeline;

class ApplicationTimelineRepository extends BaseRepository implements ApplicationTimelineRepositoryInterface
{
    public function __construct(ApplicationTimeline $model)
    {
        parent::__construct($model);
    }
}
