<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\ApplicationServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Requests\Application\SubmitApplicationRequest;
use App\Http\Requests\Application\UpdateApplicationRequest;
use App\Http\Requests\Application\UpdateApplicationStatusRequest;
use App\Http\Resources\ApplicationResource;
use App\Models\Application;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ApplicationController extends BaseApiController
{
    protected ApplicationServiceInterface $applicationService;

    public function __construct(ApplicationServiceInterface $applicationService)
    {
        $this->ApplicationService = $applicationService;
    }

    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Application::class);

        $perPage = (int) $request->get('per_page', 15);
        $paginator = $this->ApplicationService->getApplicationsForUser($request->user(), $request->all(), $perPage);

        return response()->json([
            'success' => true,
            'message' => 'Applications retrieved successfully',
            'data' => ApplicationResource::collection($paginator->items()),
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

    public function store(SubmitApplicationRequest $request): JsonResponse
    {
        $this->authorize('create', Application::class);

        $data = $request->only(['title', 'description', 'category', 'priority']);
        $files = $request->file('attachments', []);

        $application = $this->ApplicationService->createApplication($request->user(), $data, $files);

        return $this->createdResponse(new ApplicationResource($application), 'Application submitted successfully');
    }

    public function show(Application $application): JsonResponse
    {
        $this->authorize('view', $application);

        return $this->successResponse(
            new ApplicationResource($application->load(['student', 'assignedTo', 'category', 'remarks.user', 'timeline.fromUser', 'timeline.toUser'])),
            'Application details retrieved successfully'
        );
    }

    public function update(UpdateApplicationRequest $request, Application $application): JsonResponse
    {
        $this->authorize('update', $application);

        $this->ApplicationService->update($application->id, $request->validated());

        return $this->successResponse(new ApplicationResource($application->fresh()), 'Application updated successfully');
    }

    public function updateStatus(UpdateApplicationStatusRequest $request, Application $application): JsonResponse
    {
        $this->authorize('updateStatus', $application);

        $status = $request->status;
        $actor = $request->user();
        $notes = $request->notes;

        switch ($status) {
            case Application::STATUS_FORWARDED:
                if (!$request->assigned_to_id) {
                    return response()->json(['success' => false, 'message' => 'assigned_to_id is required for forwarding'], 422);
                }
                $assignTo = \App\Models\User::findOrFail($request->assigned_to_id);
                $updated = $this->ApplicationService->forward($actor, $application, $assignTo, $notes);
                break;
            case Application::STATUS_RESOLVED:
                $updated = $this->ApplicationService->resolve($actor, $application, $notes);
                break;
            case Application::STATUS_REJECTED:
                $updated = $this->ApplicationService->reject($actor, $application, $notes);
                break;
            case Application::STATUS_RETURNED:
                $updated = $this->ApplicationService->returnApplication($actor, $application, $notes);
                break;
            default:
                return response()->json(['success' => false, 'message' => 'Invalid status requested'], 422);
        }

        return $this->successResponse(new ApplicationResource($updated), 'Application status updated successfully');
    }

    public function destroy(Application $application): JsonResponse
    {
        $this->authorize('delete', $application);

        $this->ApplicationService->delete($application->id);

        return $this->successResponse(null, 'Application deleted successfully');
    }
}
