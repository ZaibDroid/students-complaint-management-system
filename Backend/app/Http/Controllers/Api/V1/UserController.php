<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\UserServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Requests\User\AssignAdviserRequest;
use App\Http\Requests\User\AssignRoleRequest;
use App\Http\Requests\User\AssignSectionsRequest;
use App\Http\Requests\User\CreateStaffRequest;
use App\Http\Requests\User\UpdateCrStatusRequest;
use App\Http\Requests\User\UpdateStaffRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends BaseApiController
{
    protected UserServiceInterface $userService;

    public function __construct(UserServiceInterface $userService)
    {
        $this->userService = $userService;
    }

    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', User::class);

        $perPage = (int) $request->get('per_page', 15);
        $paginator = $this->userService->listUsers($request->all(), $perPage);

        return response()->json([
            'success' => true,
            'message' => 'Users retrieved successfully',
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

    public function listStaff(Request $request): JsonResponse
    {
        $this->authorize('viewAny', User::class);

        $perPage = (int) $request->get('per_page', 15);
        $paginator = $this->userService->listStaff($request->all(), $perPage);

        return response()->json([
            'success' => true,
            'message' => 'Staff members retrieved successfully',
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

    public function show(User $user): JsonResponse
    {
        $this->authorize('view', $user);

        $userDetails = $this->userService->getUserDetails($user);

        return $this->successResponse(new UserResource($userDetails), 'User details retrieved successfully');
    }

    public function createStaff(CreateStaffRequest $request): JsonResponse
    {
        $this->authorize('createStaff', User::class);

        $staff = $this->userService->createStaff($request->validated());

        return $this->createdResponse(new UserResource($staff), 'Staff account created successfully');
    }

    public function updateStaff(UpdateStaffRequest $request, User $user): JsonResponse
    {
        $this->authorize('updateStaff', $user);

        $updatedStaff = $this->userService->updateStaff($user, $request->validated());

        return $this->successResponse(new UserResource($updatedStaff), 'Staff account updated successfully');
    }

    public function deleteStaff(User $user): JsonResponse
    {
        $this->authorize('deleteStaff', $user);

        $this->userService->deleteStaff($user);

        return $this->successResponse(null, 'Staff account deleted successfully');
    }

    public function assignRoles(AssignRoleRequest $request, User $user): JsonResponse
    {
        $this->authorize('assignRole', User::class);

        $updatedUser = $this->userService->assignRoles($user, $request->roles);

        return $this->successResponse(new UserResource($updatedUser), 'User roles updated successfully');
    }

    public function assignAdviser(AssignAdviserRequest $request, User $user): JsonResponse
    {
        $this->authorize('assignAdviser', User::class);

        $updatedUser = $this->userService->assignAdviser($user, $request->adviser_id);

        return $this->successResponse(new UserResource($updatedUser), 'Student adviser assigned successfully');
    }

    public function assignSections(AssignSectionsRequest $request, User $user): JsonResponse
    {
        $this->authorize('updateStaff', $user);

        $updatedUser = $this->userService->assignSections($user, $request->section_ids);

        return $this->successResponse(new UserResource($updatedUser), 'Assigned sections updated successfully');
    }

    public function updateCrStatus(UpdateCrStatusRequest $request, User $user): JsonResponse
    {
        $this->authorize('manageCr', User::class);

        $updatedUser = $this->userService->updateCrStatus($user, $request->is_cr);

        return $this->successResponse(new UserResource($updatedUser), 'Class Representative status updated');
    }

    public function listStudents(Request $request): JsonResponse
    {
        $this->authorize('viewAny', User::class);

        $perPage = (int) $request->get('per_page', 100);
        $paginator = $this->userService->listUsers(array_merge($request->all(), ['role' => 'Student']), $perPage);

        return response()->json([
            'success' => true,
            'message' => 'Students retrieved successfully',
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

    public function updateStatus(Request $request, User $user): JsonResponse
    {
        $status = $request->input('status', 'approved');
        $user->status = $status;
        $user->save();

        return $this->successResponse(new UserResource($user), 'User status updated successfully');
    }
}
