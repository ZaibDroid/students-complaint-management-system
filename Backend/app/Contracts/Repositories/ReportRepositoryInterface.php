<?php

namespace App\Contracts\Repositories;

use Illuminate\Support\Collection;

interface ReportRepositoryInterface
{
    public function getApplicationReport(array $filters): Collection;

    public function getUserReport(array $filters): Collection;

    public function getStaffPerformanceReport(array $filters): Collection;

    public function getNoticeReport(array $filters): Collection;
}
