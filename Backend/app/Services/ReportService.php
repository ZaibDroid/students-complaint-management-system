<?php

namespace App\Services;

use App\Contracts\Repositories\ReportRepositoryInterface;
use App\Contracts\Services\ReportServiceInterface;
use Illuminate\Support\Collection;

class ReportService implements ReportServiceInterface
{
    protected ReportRepositoryInterface $reportRepository;

    public function __construct(ReportRepositoryInterface $reportRepository)
    {
        $this->reportRepository = $reportRepository;
    }

    public function generateReport(string $type, array $filters = []): Collection
    {
        return match ($type) {
            'applications' => $this->reportRepository->getApplicationReport($filters),
            'users' => $this->reportRepository->getUserReport($filters),
            'staff-performance' => $this->reportRepository->getStaffPerformanceReport($filters),
            'notices' => $this->reportRepository->getNoticeReport($filters),
            default => $this->reportRepository->getApplicationReport($filters),
        };
    }

    public function exportCsv(Collection $data, string $reportName): string
    {
        if ($data->isEmpty()) {
            return "No data available for export";
        }

        $array = $data->toArray();
        $output = fopen('php://temp', 'r+');

        // CSV Header
        fputcsv($output, array_keys(reset($array)));

        foreach ($array as $row) {
            $formattedRow = array_map(function ($value) {
                return is_array($value) ? json_encode($value) : $value;
            }, $row);
            fputcsv($output, $formattedRow);
        }

        rewind($output);
        $csvContent = stream_get_contents($output);
        fclose($output);

        return $csvContent;
    }
}
