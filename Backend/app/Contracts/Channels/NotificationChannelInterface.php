<?php

namespace App\Contracts\Channels;

use App\Models\User;
use App\Enums\NotificationType;
use Illuminate\Database\Eloquent\Model;

interface NotificationChannelInterface
{
    public function send(User $user, NotificationType $type, string $title, string $message, ?Model $reference = null): void;
}
