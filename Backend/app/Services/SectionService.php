<?php

namespace App\Services;

use App\Contracts\Repositories\SectionRepositoryInterface;
use App\Contracts\Services\SectionServiceInterface;
use App\Models\Section;

class SectionService extends BaseService implements SectionServiceInterface
{
    public function __construct(SectionRepositoryInterface $repository)
    {
        parent::__construct($repository);
    }

    public function assignAdviserToSection(Section $section, int $adviserId): Section
    {
        $this->repository->assignAdviserToSection($section, $adviserId);
        return $section->fresh(['batch', 'assignedStaff']);
    }

    public function removeAdviserFromSection(Section $section, int $adviserId): Section
    {
        $this->repository->removeAdviserFromSection($section, $adviserId);
        return $section->fresh(['batch', 'assignedStaff']);
    }
}
