<?php

namespace App\Channels;

use App\Contracts\Channels\NotificationChannelInterface;
use App\Models\User;
use App\Enums\NotificationType;
use App\Models\Notification;
use Illuminate\Database\Eloquent\Model;

class DatabaseNotificationChannel implements NotificationChannelInterface
{
    public function send(User $user, NotificationType $type, string $title, string $message, ?Model $reference = null): void
    {
        Notification::create([
            'user_id' => $user->id,
            'type' => $type,
            'title' => $title,
            'message' => $message,
            'reference_type' => $reference ? get_class($reference) : null,
            'reference_id' => $reference ? $reference->id : null,
        ]);
    }
}
