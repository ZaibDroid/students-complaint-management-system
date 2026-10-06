<?php

namespace App\Contracts\Services;

use App\Models\Section;

interface SectionServiceInterface extends BaseServiceInterface
{
    public function assignAdviserToSection(Section $section, int $adviserId): Section;

    public function removeAdviserFromSection(Section $section, int $adviserId): Section;
}
