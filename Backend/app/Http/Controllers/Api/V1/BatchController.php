<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\BatchServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Requests\Batch\CreateBatchRequest;
use App\Http\Requests\Batch\UpdateBatchRequest;
use App\Http\Resources\BatchResource;
use App\Models\Batch;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BatchController extends BaseApiController
{
    protected BatchServiceInterface $batchService;

    public function __construct(BatchServiceInterface $batchService)
    {
        $this->batchService = $batchService;
    }

    public function index(Request $request): JsonResponse
    {
        $user = $request->user() ?? auth('sanctum')->user();
        $isStaff = $user && $user->hasAnyRole(['Chairman', 'Admin', 'Department Office', 'Coordinator', 'Batch Advisor', 'Batch Adviser']);
        $forRegistration = !$isStaff || $request->boolean('for_registration') || $request->boolean('has_coordinator') || ($user && $user->hasRole('Student'));

        $defaultPerPage = ($user && $user->hasRole('Coordinator')) ? 15 : 100;
        $perPage = (int) $request->get('per_page', $defaultPerPage);
        $filters = $request->all();

        if ($user && $user->hasRole('Coordinator')) {
            $coordinatorBatchIds = $user->getAssignedBatchIds();
            $filters['id'] = !empty($coordinatorBatchIds) ? $coordinatorBatchIds : [-1];
        }

        if ($forRegistration) {
            // For public / registration: strictly active batches with active assigned coordinators and active sections
            $filters['is_active'] = 1;
            $filters['hasActiveCoordinator'] = true;
            $withRelations = [
                'sections' => fn($q) => $q->where('is_active', true),
            ];
        } else {
            $withRelations = ['sections.assignedStaff', 'coordinator'];
        }

        $paginator = $this->batchService->getPaginated($perPage, $withRelations, $filters);

        // De-duplicate canonical batch entries so each batch appears only once
        $items = collect($paginator->items())->unique(function ($b) {
            return ($b->start_year && $b->end_year)
                ? "{$b->start_year}-{$b->end_year}"
                : trim(str_ireplace('batch', '', (string)$b->name));
        })->values();

        return response()->json([
            'success' => true,
            'message' => 'Batches retrieved successfully',
            'data' => BatchResource::collection($items),
            'meta' => [
                'pagination' => [
                    'total' => $items->count(),
                    'count' => $items->count(),
                    'per_page' => $paginator->perPage(),
                    'current_page' => $paginator->currentPage(),
                    'total_pages' => $paginator->lastPage(),
                ],
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    public function store(CreateBatchRequest $request): JsonResponse
    {
        $this->authorize('create', Batch::class);

        $validated = $request->validated();
        $rawSections = $validated['sections'] ?? [];
        unset($validated['sections']);

        /** @var Batch $batch */
        $batch = $this->batchService->create($validated);

        $sectionNames = [];
        if (is_array($rawSections)) {
            foreach ($rawSections as $item) {
                $strItem = trim((string)$item);
                if (is_numeric($strItem) && (int)$strItem > 0) {
                    $count = (int)$strItem;
                    for ($i = 0; $i < min($count, 26); $i++) {
                        $sectionNames[] = chr(65 + $i); // Generates A, B, C, D...
                    }
                } elseif (str_contains($strItem, ',')) {
                    $parts = explode(',', $strItem);
                    foreach ($parts as $p) {
                        if (trim($p) !== '') {
                            $sectionNames[] = trim($p);
                        }
                    }
                } elseif ($strItem !== '') {
                    $sectionNames[] = $strItem;
                }
            }
        } elseif (is_numeric($rawSections) && (int)$rawSections > 0) {
            $count = (int)$rawSections;
            for ($i = 0; $i < min($count, 26); $i++) {
                $sectionNames[] = chr(65 + $i);
            }
        } elseif (is_string($rawSections) && trim($rawSections) !== '') {
            $sectionNames[] = trim($rawSections);
        }

        if (empty($sectionNames)) {
            $sectionNames = ['A'];
        }

        foreach (array_unique($sectionNames) as $sName) {
            $existing = $batch->sections()->withTrashed()
                ->where(function ($q) use ($sName) {
                    $q->where('name', $sName)
                      ->orWhere('name', 'Section ' . $sName);
                })->first();

            if ($existing) {
                if ($existing->trashed()) {
                    $existing->restore();
                }
                $existing->update([
                    'name' => $sName,
                    'is_active' => true,
                ]);
            } else {
                $batch->sections()->create([
                    'name' => $sName,
                    'is_active' => true,
                ]);
            }
        }

        return $this->createdResponse(new BatchResource($batch->fresh(['sections'])), 'Batch created successfully');
    }

    public function show(Batch $batch): JsonResponse
    {
        return $this->successResponse(new BatchResource($batch->load('sections')), 'Batch details retrieved');
    }

    public function update(UpdateBatchRequest $request, Batch $batch): JsonResponse
    {
        $this->authorize('update', $batch);

        $validated = $request->validated();
        $hasSections = array_key_exists('sections', $validated);
        $rawSections = $validated['sections'] ?? [];
        unset($validated['sections']);

        if (!empty($validated)) {
            $this->batchService->update($batch->id, $validated);
        }

        if ($hasSections) {
            $incomingSections = [];
            if (is_array($rawSections)) {
                foreach ($rawSections as $item) {
                    $clean = trim((string)$item);
                    if ($clean !== '') {
                        $clean = trim(preg_replace('/^(section\s*|sec\s*)/i', '', $clean));
                        if ($clean !== '') {
                            $incomingSections[] = $clean;
                        }
                    }
                }
            }
            $incomingSections = array_values(array_unique($incomingSections));

            // Sync sections:
            // 1. Delete sections that are no longer in incomingSections
            $batch->sections()->whereNotIn('name', $incomingSections)->delete();

            // 2. Add or restore sections
            foreach ($incomingSections as $secName) {
                $existing = $batch->sections()->withTrashed()
                    ->where(function ($q) use ($secName) {
                        $q->where('name', $secName)
                          ->orWhere('name', 'Section ' . $secName);
                    })->first();

                if ($existing) {
                    if ($existing->trashed()) {
                        $existing->restore();
                    }
                    $existing->update([
                        'name' => $secName,
                        'is_active' => true,
                    ]);
                } else {
                    $batch->sections()->create([
                        'name' => $secName,
                        'is_active' => true,
                    ]);
                }
            }
        }

        return $this->successResponse(new BatchResource($batch->fresh(['sections'])), 'Batch updated successfully');
    }

    public function destroy(Batch $batch): JsonResponse
    {
        $this->authorize('delete', $batch);

        $this->batchService->delete($batch->id);

        return $this->successResponse(null, 'Batch deleted successfully');
    }
}
