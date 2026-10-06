<?php

namespace App\Contracts\Repositories;

use App\Models\User;
use App\Models\Notification;
use Illuminate\Pagination\LengthAwarePaginator;

interface NotificationRepositoryInterface extends BaseRepositoryInterface
{
    public function paginateForUser(User $user, array $filters = []): LengthAwarePaginator;
    
    public function markAsRead(Notification $notification): void;

    public function markAllAsRead(User $user): void;
}
