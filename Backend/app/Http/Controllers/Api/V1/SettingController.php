<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\SettingServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Requests\Setting\UpdateSettingRequest;
use App\Http\Resources\SettingResource;
use App\Models\Setting;
use Illuminate\Http\JsonResponse;

class SettingController extends BaseApiController
{
    protected SettingServiceInterface $settingService;

    public function __construct(SettingServiceInterface $settingService)
    {
        $this->settingService = $settingService;
    }

    public function index(): JsonResponse
    {
        $settings = $this->settingService->getSettings();

        return $this->successResponse(SettingResource::collection($settings), 'System settings retrieved successfully');
    }

    public function update(UpdateSettingRequest $request): JsonResponse
    {
        $this->authorize('update', Setting::class);

        $updatedSettings = $this->settingService->updateSettings($request->settings);

        return $this->successResponse(SettingResource::collection($updatedSettings), 'System settings updated successfully');
    }
}
