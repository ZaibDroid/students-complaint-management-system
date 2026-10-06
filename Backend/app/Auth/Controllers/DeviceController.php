<?php

namespace App\Auth\Controllers;

use App\Auth\Services\DeviceService;
use App\Http\Controllers\Api\V1\BaseApiController;
use App\Models\UserDevice;
use Illuminate\Http\JsonResponse;

class DeviceController extends BaseApiController
{
    public function __construct(protected DeviceService $deviceService) {}

    public function index(): JsonResponse
    {
        $devices = request()->user()->devices()->whereNull('revoked_at')->get();
        return $this->successResponse($devices, 'Active devices retrieved successfully.');
    }

    public function revoke(UserDevice $device): JsonResponse
    {
        if ($device->user_id !== request()->user()->id) {
            abort(403, 'Unauthorized to revoke this device.');
        }

        $this->deviceService->revokeDevice($device);

        // Revoke the Sanctum token created by this device if we could track it (usually requires tying token ID to device table)
        // For now, rotating refresh token to null prevents future refreshes, 
        // and the EnsureDeviceIsActive middleware will block the current short-lived token immediately.
        
        event(new \App\Auth\Events\DeviceRevoked($device));

        return $this->successResponse([], 'Device revoked successfully.');
    }
}
