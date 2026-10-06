<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Repositories\NotificationRepositoryInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Resources\NotificationResource;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends BaseApiController
{
    protected NotificationRepositoryInterface $notificationRepository;

    public function __construct(NotificationRepositoryInterface $notificationRepository)
    {
        $this->notificationRepository = $notificationRepository;
    }

    public function index(Request $request): JsonResponse
    {
        $paginator = $this->notificationRepository->paginateForUser($request->user(), $request->all());

        return response()->json([
            'success' => true,
            'message' => 'Notifications retrieved successfully',
            'data' => NotificationResource::collection($paginator->items()),
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

    public function markAsRead(Notification $notification): JsonResponse
    {
        $this->authorize('update', $notification);

        $this->notificationRepository->markAsRead($notification);

        return $this->successResponse(new NotificationResource($notification->fresh()), 'Notification marked as read');
    }

    public function markAllAsRead(Request $request): JsonResponse
    {
        $this->notificationRepository->markAllAsRead($request->user());

        return $this->successResponse(null, 'All notifications marked as read');
    }

    public function destroy(Notification $notification): JsonResponse
    {
        $this->authorize('delete', $notification);

        $this->notificationRepository->delete($notification->id);

        return $this->successResponse(null, 'Notification deleted successfully');
    }
}
