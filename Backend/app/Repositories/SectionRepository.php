<?php

namespace App\Repositories;

use App\Contracts\Repositories\SectionRepositoryInterface;
use App\Models\Section;

class SectionRepository extends BaseRepository implements SectionRepositoryInterface
{
    public function __construct(Section $model)
    {
        parent::__construct($model);
    }

    public function assignAdviserToSection(Section $section, int $adviserId): void
    {
        $section->assignedStaff()->syncWithoutDetaching([$adviserId]);
    }

    public function removeAdviserFromSection(Section $section, int $adviserId): void
    {
        $section->assignedStaff()->detach($adviserId);
    }
}
