<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\DepartmentServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Requests\Department\CreateDepartmentRequest;
use App\Http\Requests\Department\UpdateDepartmentRequest;
use App\Http\Resources\DepartmentResource;
use App\Models\Department;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DepartmentController extends BaseApiController
{
    protected DepartmentServiceInterface $departmentService;

    public function __construct(DepartmentServiceInterface $departmentService)
    {
        $this->departmentService = $departmentService;
    }

    public function index(Request $request): JsonResponse
    {
        $perPage = (int) $request->get('per_page', 15);
        $paginator = $this->departmentService->getPaginated($perPage, [], $request->all());

        return response()->json([
            'success' => true,
            'message' => 'Departments retrieved successfully',
            'data' => DepartmentResource::collection($paginator->items()),
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

    public function store(CreateDepartmentRequest $request): JsonResponse
    {
        $this->authorize('create', Department::class);

        $department = $this->departmentService->create($request->validated());

        return $this->createdResponse(new DepartmentResource($department), 'Department created successfully');
    }

    public function show(Department $department): JsonResponse
    {
        return $this->successResponse(new DepartmentResource($department), 'Department details retrieved');
    }

    public function update(UpdateDepartmentRequest $request, Department $department): JsonResponse
    {
        $this->authorize('update', $department);

        $this->departmentService->update($department->id, $request->validated());

        return $this->successResponse(new DepartmentResource($department->fresh()), 'Department updated successfully');
    }

    public function destroy(Department $department): JsonResponse
    {
        $this->authorize('delete', $department);

        $this->departmentService->delete($department->id);

        return $this->successResponse(null, 'Department deleted successfully');
    }
}
