<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseApiController;
use App\Http\Resources\ApplicationTimelineResource;
use App\Models\Application;
use Illuminate\Http\JsonResponse;

class ApplicationTimelineController extends BaseApiController
{
    public function index(Application $application): JsonResponse
    {
        $this->authorize('view', $application);

        return $this->successResponse(
            ApplicationTimelineResource::collection($application->timeline->load(['fromUser', 'toUser'])),
            'Application timeline retrieved successfully'
        );
    }
}
