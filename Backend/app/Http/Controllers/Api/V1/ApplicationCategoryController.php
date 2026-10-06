<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseApiController;
use App\Http\Resources\ApplicationCategoryResource;
use App\Models\ApplicationCategory;
use Illuminate\Http\JsonResponse;

class ApplicationCategoryController extends BaseApiController
{
    public function index(): JsonResponse
    {
        $categories = ApplicationCategory::where('is_active', true)->get();

        return $this->successResponse(
            ApplicationCategoryResource::collection($categories),
            'Application categories retrieved successfully'
        );
    }
}

