<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\AppNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class NotificationController extends BaseApiController
{
    /**
     * List user notifications
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $notifications = AppNotification::where('user_id', $user->id)
            ->latest()
            ->get()
            ->map(fn(AppNotification $n) => $n->toResponseArray())
            ->values()
            ->all();

        return $this->success($notifications, 'Notifications retrieved.');
    }

    /**
     * Mark single notification as read
     */
    public function markAsRead(Request $request, string $id): JsonResponse
    {
        $notification = AppNotification::where('user_id', $request->user()->id)->find($id);
        if (!$notification) {
            return $this->error('Notification not found.', 404);
        }

        $notification->is_read = true;
        $notification->save();

        return $this->success(null, 'Marked as read.');
    }

    /**
     * Mark all notifications as read
     */
    public function markAllRead(Request $request): JsonResponse
    {
        AppNotification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return $this->success(null, 'All notifications marked as read.');
    }

    /**
     * Register FCM Push Notification Device Token
     */
    public function registerFcmToken(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'fcmToken' => ['sometimes', 'string'],
            'fcm_token' => ['sometimes', 'string'],
            'token' => ['sometimes', 'string'],
        ]);

        if ($validator->fails()) {
            return $this->error('Token error', 422, $validator->errors());
        }

        $token = $request->fcmToken ?? $request->fcm_token ?? $request->token;
        if (!empty($token)) {
            $user = $request->user();
            $user->fcm_token = $token;
            $user->save();
        }

        return $this->success(null, 'FCM token registered successfully.');
    }
}
