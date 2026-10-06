<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\UserServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Requests\User\UpdateCrStatusRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CrManagementController extends BaseApiController
{
    protected UserServiceInterface $userService;

    public function __construct(UserServiceInterface $userService)
    {
        $this->userService = $userService;
    }

    public function index(Request $request): JsonResponse
    {
        $perPage = (int) $request->get('per_page', 15);
        $filters = array_merge($request->all(), ['is_cr' => true]);

        $paginator = $this->userService->listUsers($filters, $perPage);

        return response()->json([
            'success' => true,
            'message' => 'Class Representatives directory retrieved successfully',
            'data' => UserResource::collection($paginator->items()),
            'meta' => [
                'pagination' => [
                    'total' => $paginator->total(),
                    'count' => $paginator->count(),
                    'per_page' => $paginator->perPage(),
                    'current_page' => $paginator->currentPage(),
                    'total_pages' => $paginator->lastPage(),
                ],
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    public function updateStatus(UpdateCrStatusRequest $request, User $user): JsonResponse
    {
        $this->authorize('manageCr', User::class);

        $updatedUser = $this->userService->updateCrStatus($user, $request->is_cr);

        $statusMsg = $request->is_cr ? 'Student promoted to Class Representative' : 'Class Representative status removed';

        return $this->successResponse(new UserResource($updatedUser), $statusMsg);
    }
}
