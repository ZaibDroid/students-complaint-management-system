<?php

namespace App\Services;

use App\Models\AppNotification;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmService
{
    /**
     * Send Push Notification to a specific user and record in database.
     */
    public static function sendToUser(User $user, string $title, string $message, string $type = 'general', ?string $referenceId = null): void
    {
        // 1. Create In-App Notification record
        AppNotification::create([
            'user_id' => $user->id,
            'title' => $title,
            'message' => $message,
            'type' => $type,
            'reference_id' => $referenceId,
            'is_read' => false,
        ]);

        // 2. Dispatch FCM Push Notification if user has registered FCM device token
        if (!empty($user->fcm_token)) {
            self::sendFcmRaw($user->fcm_token, $title, $message, [
                'type' => $type,
                'reference_id' => $referenceId ?? '',
            ]);
        }
    }

    /**
     * Send Push Notification to all users with a specific role.
     */
    public static function sendToRole(string $role, string $title, string $message, string $type = 'general', ?string $referenceId = null): void
    {
        $users = User::where('role', $role)->get();
        foreach ($users as $user) {
            self::sendToUser($user, $title, $message, $type, $referenceId);
        }
    }

    /**
     * Send Push Notification to a batch of students (e.g. for notices or batch announcements).
     */
    public static function sendToBatch(string $batchName, string $title, string $message, string $type = 'notice', ?string $referenceId = null): void
    {
        $students = User::where('batch', $batchName)->get();
        foreach ($students as $student) {
            self::sendToUser($student, $title, $message, $type, $referenceId);
        }
    }

    /**
     * Raw FCM HTTP dispatch.
     */
    private static function sendFcmRaw(string $fcmToken, string $title, string $body, array $data = []): void
    {
        $serverKey = config('dcms.fcm.server_key');
        if (empty($serverKey)) {
            Log::info("FCM Notification (Server key not set, simulated): [{$title}] {$body} to {$fcmToken}");
            return;
        }

        try {
            Http::withHeaders([
                'Authorization' => 'key=' . $serverKey,
                'Content-Type' => 'application/json',
            ])->post('https://fcm.googleapis.com/fcm/send', [
                'to' => $fcmToken,
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                    'sound' => 'default',
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ],
                'data' => array_merge($data, [
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ]),
                'priority' => 'high',
            ]);
        } catch (\Exception $e) {
            Log::error('FCM Dispatch Error: ' . $e->getMessage());
        }
    }
}
