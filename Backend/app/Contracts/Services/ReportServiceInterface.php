<?php

namespace App\Contracts\Services;

use Illuminate\Support\Collection;

interface ReportServiceInterface
{
    public function generateReport(string $type, array $filters = []): Collection;

    public function exportCsv(Collection $data, string $reportName): string;
}
