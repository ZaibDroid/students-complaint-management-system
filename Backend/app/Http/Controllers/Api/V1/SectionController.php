<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\SectionServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Requests\Section\AssignSectionAdviserRequest;
use App\Http\Requests\Section\CreateSectionRequest;
use App\Http\Requests\Section\UpdateSectionRequest;
use App\Http\Resources\SectionResource;
use App\Models\Section;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SectionController extends BaseApiController
{
    protected SectionServiceInterface $sectionService;

    public function __construct(SectionServiceInterface $sectionService)
    {
        $this->sectionService = $sectionService;
    }

    public function index(Request $request): JsonResponse
    {
        $user = $request->user() ?? auth('sanctum')->user();
        $defaultPerPage = ($user && $user->hasRole('Coordinator')) ? 15 : 100;
        $perPage = (int) $request->get('per_page', $defaultPerPage);
        $filters = $request->all();

        if ($user && $user->hasRole('Coordinator')) {
            $coordinatorBatchIds = $user->getAssignedBatchIds();
            if (isset($filters['batch_id']) && is_numeric($filters['batch_id'])) {
                if (!in_array((int)$filters['batch_id'], $coordinatorBatchIds, true)) {
                    $filters['batch_id'] = -1;
                }
            } else {
                $filters['batch_id'] = !empty($coordinatorBatchIds) ? $coordinatorBatchIds : [-1];
            }
        }

        $withRelations = ['batch'];
        if ($user && $user->hasAnyRole(['Chairman', 'Admin', 'Department Office', 'Coordinator', 'Batch Advisor', 'Batch Adviser'])) {
            $withRelations[] = 'assignedStaff';
        } else {
            // For public / registration: only active sections
            $filters['is_active'] = 1;
        }

        $paginator = $this->sectionService->getPaginated($perPage, $withRelations, $filters);

        return response()->json([
            'success' => true,
            'message' => 'Sections retrieved successfully',
            'data' => SectionResource::collection($paginator->items()),
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

    public function store(CreateSectionRequest $request): JsonResponse
    {
        $this->authorize('create', Section::class);

        $section = $this->sectionService->create($request->validated());

        return $this->createdResponse(new SectionResource($section->load('batch')), 'Section created successfully');
    }

    public function show(Section $section): JsonResponse
    {
        return $this->successResponse(new SectionResource($section->load(['batch', 'assignedStaff'])), 'Section details retrieved');
    }

    public function update(UpdateSectionRequest $request, Section $section): JsonResponse
    {
        $this->authorize('update', $section);

        $this->sectionService->update($section->id, $request->validated());

        return $this->successResponse(new SectionResource($section->fresh(['batch', 'assignedStaff'])), 'Section updated successfully');
    }

    public function destroy(Section $section): JsonResponse
    {
        $this->authorize('delete', $section);

        $this->sectionService->delete($section->id);

        return $this->successResponse(null, 'Section deleted successfully');
    }

    public function assignAdviser(AssignSectionAdviserRequest $request, Section $section): JsonResponse
    {
        $this->authorize('assignAdviser', $section);

        if (empty($request->adviser_id)) {
            $section->assignedStaff()->detach();
            $updatedSection = $section->fresh(['batch', 'assignedStaff']);
        } else {
            $adviser = User::find((int)$request->adviser_id);
            if (!$adviser || !$adviser->hasAnyRole(['Batch Adviser', 'Batch Advisor'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'The selected user is not a valid Batch Adviser.',
                ], 422);
            }

            $sectionDeptId = $section->batch?->department_id;
            if ($sectionDeptId && $adviser->department_id && (int)$adviser->department_id !== (int)$sectionDeptId) {
                return response()->json([
                    'success' => false,
                    'message' => 'The selected adviser belongs to a different department.',
                ], 422);
            }

            $updatedSection = $this->sectionService->assignAdviserToSection($section, (int)$request->adviser_id);
        }

        return $this->successResponse(new SectionResource($updatedSection), 'Adviser assigned to section successfully');
    }

    public function removeAdviser(Request $request, Section $section, int $adviserId): JsonResponse
    {
        $this->authorize('assignAdviser', $section);

        $updatedSection = $this->sectionService->removeAdviserFromSection($section, $adviserId);

        return $this->successResponse(new SectionResource($updatedSection), 'Adviser removed from section successfully');
    }
}
