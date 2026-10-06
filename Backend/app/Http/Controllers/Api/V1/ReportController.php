<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\ReportServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ReportController extends BaseApiController
{
    protected ReportServiceInterface $reportService;

    public function __construct(ReportServiceInterface $reportService)
    {
        $this->reportService = $reportService;
    }

    public function generate(Request $request): mixed
    {
        $type = $request->get('type', 'applications');
        $format = strtolower($request->get('format', 'json'));

        $reportData = $this->reportService->generateReport($type, $request->all());

        if ($format === 'csv') {
            $csvContent = $this->reportService->exportCsv($reportData, $type);
            return response($csvContent, Response::HTTP_OK, [
                'Content-Type' => 'text/csv',
                'Content-Disposition' => "attachment; filename=\"{$type}_report_" . date('Y-m-d') . ".csv\"",
            ]);
        }

        return $this->successResponse([
            'report_type' => $type,
            'total_records' => $reportData->count(),
            'records' => $reportData,
        ], 'Report generated successfully');
    }
}
