<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\DashboardServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends BaseApiController
{
    protected DashboardServiceInterface $dashboardService;

    public function __construct(DashboardServiceInterface $dashboardService)
    {
        $this->dashboardService = $dashboardService;
    }

    public function index(Request $request): JsonResponse
    {
        $data = $this->dashboardService->getDashboardForUser($request->user());

        return $this->successResponse(
            new \App\Http\Resources\DashboardResource($data), 
            'Dashboard metrics retrieved successfully'
        );
    }

    public function getCharts(Request $request): JsonResponse
    {
        $type = $request->get('type', 'Applications-by-status');
        $chartsData = $this->dashboardService->getChartsData($type, $request->all());

        return $this->successResponse($chartsData, 'Chart metrics retrieved successfully');
    }
}
