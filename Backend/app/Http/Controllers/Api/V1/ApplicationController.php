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
        $this->applicationService = $applicationService;
    }

    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Application::class);

        $perPage = (int) $request->get('per_page', 15);
        $paginator = $this->applicationService->getApplicationsForUser($request->user(), $request->all(), $perPage);

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

        $categoryId = $request->input('category_id');
        if (!$categoryId && $request->filled('category')) {
            $catInput = trim((string)$request->input('category'));
            if (is_numeric($catInput)) {
                $categoryId = (int) $catInput;
            } else {
                $categoryModel = \App\Models\ApplicationCategory::where('name', 'LIKE', '%' . $catInput . '%')
                    ->orWhere('slug', 'LIKE', '%' . \Illuminate\Support\Str::slug($catInput) . '%')
                    ->first();
                if (!$categoryModel) {
                    $firstWord = explode(' ', $catInput)[0];
                    $categoryModel = \App\Models\ApplicationCategory::where('name', 'LIKE', '%' . $firstWord . '%')->first();
                }
                $categoryId = $categoryModel?->id;
            }
        }

        if (!$categoryId) {
            $categoryId = \App\Models\ApplicationCategory::where('is_active', true)->first()?->id ?? 1;
        }

        $data = $request->only(['title', 'description', 'priority']);
        $data['category_id'] = $categoryId;

        $files = [];
        if ($request->hasFile('attachment')) {
            $files['attachment'] = $request->file('attachment');
        }
        if ($request->hasFile('attachments')) {
            $attachmentFiles = $request->file('attachments');
            $files['attachments'] = is_array($attachmentFiles) ? $attachmentFiles : [$attachmentFiles];
        }

        $application = $this->applicationService->createApplication($request->user(), $data, $files);

        return $this->createdResponse(new ApplicationResource($application), 'Application submitted successfully');
    }

    public function show(Application $application): JsonResponse
    {
        $this->authorize('view', $application);

        return $this->successResponse(
            new ApplicationResource($application->load(['department', 'attachments', 'student', 'assignedTo', 'category', 'remarks.user', 'timeline.fromUser', 'timeline.toUser'])),
            'Application details retrieved successfully'
        );
    }

    public function update(UpdateApplicationRequest $request, Application $application): JsonResponse
    {
        $this->authorize('update', $application);

        $this->applicationService->update($application->id, $request->validated());

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
                $updated = $this->applicationService->forward($actor, $application, $assignTo, $notes);
                break;
            case Application::STATUS_RESOLVED:
                $updated = $this->applicationService->resolve($actor, $application, $notes);
                break;
            case Application::STATUS_REJECTED:
                $updated = $this->applicationService->reject($actor, $application, $notes);
                break;
            case Application::STATUS_RETURNED:
                $updated = $this->applicationService->returnApplication($actor, $application, $notes);
                break;
            default:
                return response()->json(['success' => false, 'message' => 'Invalid status requested'], 422);
        }

        return $this->successResponse(new ApplicationResource($updated), 'Application status updated successfully');
    }

    public function destroy(Application $application): JsonResponse
    {
        $this->authorize('delete', $application);

        $this->applicationService->delete($application->id);

        return $this->successResponse(null, 'Application deleted successfully');
    }
}
