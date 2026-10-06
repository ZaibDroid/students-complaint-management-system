<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\ApplicationServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Requests\Application\AddRemarkRequest;
use App\Http\Resources\ApplicationRemarkResource;
use App\Models\Application;
use Illuminate\Http\JsonResponse;

class ApplicationRemarkController extends BaseApiController
{
    protected ApplicationServiceInterface $applicationService;

    public function __construct(ApplicationServiceInterface $applicationService)
    {
        $this->ApplicationService = $applicationService;
    }

    public function index(Application $application): JsonResponse
    {
        $this->authorize('view', $application);

        return $this->successResponse(
            ApplicationRemarkResource::collection($application->remarks->load('user')),
            'Remarks retrieved successfully'
        );
    }

    public function store(AddRemarkRequest $request, Application $application): JsonResponse
    {
        $this->authorize('addRemark', $application);

        $remark = $this->ApplicationService->addRemark(
            $request->user(),
            $application,
            $request->remark,
            $request->action_taken
        );

        return $this->createdResponse(new ApplicationRemarkResource($remark), 'Remark added successfully');
    }
}
