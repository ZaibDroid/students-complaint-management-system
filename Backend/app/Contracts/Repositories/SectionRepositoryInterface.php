<?php

namespace App\Contracts\Repositories;

use App\Models\Section;

interface SectionRepositoryInterface extends BaseRepositoryInterface
{
    public function assignAdviserToSection(Section $section, int $adviserId): void;

    public function removeAdviserFromSection(Section $section, int $adviserId): void;
}
