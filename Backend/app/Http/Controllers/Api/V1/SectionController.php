<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\SectionServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Requests\Section\AssignSectionAdviserRequest;
use App\Http\Requests\Section\CreateSectionRequest;
use App\Http\Requests\Section\UpdateSectionRequest;
use App\Http\Resources\SectionResource;
use App\Models\Section;
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
        $perPage = (int) $request->get('per_page', 15);
        $paginator = $this->sectionService->getPaginated($perPage, ['batch', 'assignedStaff'], $request->all());

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
        $this->authorize('assignAdviser', Section::class);

        $updatedSection = $this->sectionService->assignAdviserToSection($section, $request->adviser_id);

        return $this->successResponse(new SectionResource($updatedSection), 'Adviser assigned to section successfully');
    }

    public function removeAdviser(Request $request, Section $section, int $adviserId): JsonResponse
    {
        $this->authorize('assignAdviser', Section::class);

        $updatedSection = $this->sectionService->removeAdviserFromSection($section, $adviserId);

        return $this->successResponse(new SectionResource($updatedSection), 'Adviser removed from section successfully');
    }
}
