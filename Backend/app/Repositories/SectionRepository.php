<?php

namespace App\Repositories;

use App\Contracts\Repositories\SectionRepositoryInterface;
use App\Models\Section;
use App\Models\User;

class SectionRepository extends BaseRepository implements SectionRepositoryInterface
{
    public function __construct(Section $model)
    {
        parent::__construct($model);
    }

    public function assignAdviserToSection(Section $section, int $adviserId): void
    {
        $section->assignedStaff()->sync([$adviserId]);
        $adviser = User::find($adviserId);
        if ($adviser) {
            $adviser->update([
                'batch_id' => $section->batch_id,
                'section_id' => $section->id,
            ]);
        }
    }

    public function removeAdviserFromSection(Section $section, int $adviserId): void
    {
        $section->assignedStaff()->detach($adviserId);
    }
}
