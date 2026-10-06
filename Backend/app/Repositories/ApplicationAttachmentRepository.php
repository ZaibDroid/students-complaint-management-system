<?php

namespace App\Repositories;

use App\Contracts\Repositories\ApplicationAttachmentRepositoryInterface;
use App\Models\ApplicationAttachment;

class ApplicationAttachmentRepository extends BaseRepository implements ApplicationAttachmentRepositoryInterface
{
    public function __construct(ApplicationAttachment $model)
    {
        parent::__construct($model);
    }
}
