<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\NoticeServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Requests\Notice\CreateNoticeRequest;
use App\Http\Requests\Notice\UpdateNoticeRequest;
use App\Http\Resources\NoticeResource;
use App\Models\Notice;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NoticeController extends BaseApiController
{
    protected NoticeServiceInterface $noticeService;

    public function __construct(NoticeServiceInterface $noticeService)
    {
        $this->noticeService = $noticeService;
    }

    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Notice::class);

        $perPage = (int) $request->get('per_page', 15);
        $paginator = $this->noticeService->getNoticesForUser($request->user(), $request->all(), $perPage);

        return response()->json([
            'success' => true,
            'message' => 'Notices retrieved successfully',
            'data' => NoticeResource::collection($paginator->items()),
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

    public function store(CreateNoticeRequest $request): JsonResponse
    {
        $this->authorize('create', Notice::class);

        $data = $request->only(['title', 'description', 'tag', 'status', 'scheduled_at']);
        $targets = $request->get('targets', []);
        
        $attachments = [];
        if ($request->hasFile('attachments')) {
            $attachments = $request->file('attachments');
            if (!is_array($attachments)) {
                $attachments = [$attachments];
            }
        }

        $notice = $this->noticeService->createNotice($request->user(), $data, $targets, $attachments);

        return $this->createdResponse(new NoticeResource($notice), 'Notice created successfully');
    }

    public function show(Notice $notice): JsonResponse
    {
        $this->authorize('view', $notice);

        return $this->successResponse(
            new NoticeResource($notice->load(['sender', 'targets', 'attachments'])),
            'Notice details retrieved successfully'
        );
    }

    public function update(UpdateNoticeRequest $request, Notice $notice): JsonResponse
    {
        $this->authorize('update', $notice);

        $data = $request->only(['title', 'description', 'tag', 'status', 'scheduled_at']);
        $targets = $request->get('targets');
        
        $attachments = [];
        if ($request->hasFile('attachments')) {
            $attachments = $request->file('attachments');
            if (!is_array($attachments)) {
                $attachments = [$attachments];
            }
        }

        $updatedNotice = $this->noticeService->updateNotice($notice, $data, $targets, $attachments);

        return $this->successResponse(new NoticeResource($updatedNotice), 'Notice updated successfully');
    }

    public function destroy(Notice $notice): JsonResponse
    {
        $this->authorize('delete', $notice);

        $this->noticeService->delete($notice->id);

        return $this->successResponse(null, 'Notice deleted successfully');
    }
}
