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
        $perPage = (int) $request->get('per_page', 15);
        $paginator = $this->batchService->getPaginated($perPage, ['sections'], $request->all());

        return response()->json([
            'success' => true,
            'message' => 'Batches retrieved successfully',
            'data' => BatchResource::collection($paginator->items()),
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
            $batch->sections()->firstOrCreate(['name' => $sName]);
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

        $this->batchService->update($batch->id, $request->validated());

        return $this->successResponse(new BatchResource($batch->fresh(['sections'])), 'Batch updated successfully');
    }

    public function destroy(Batch $batch): JsonResponse
    {
        $this->authorize('delete', $batch);

        $this->batchService->delete($batch->id);

        return $this->successResponse(null, 'Batch deleted successfully');
    }
}
