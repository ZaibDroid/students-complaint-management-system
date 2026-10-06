<?php

namespace App\Repositories;

use App\Contracts\Repositories\NotificationRepositoryInterface;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;

class NotificationRepository extends BaseRepository implements NotificationRepositoryInterface
{
    public function __construct(Notification $model)
    {
        parent::__construct($model);
    }

    public function paginateForUser(User $user, array $filters = []): LengthAwarePaginator
    {
        $query = $this->model->where('user_id', $user->id)->with('reference');

        if (isset($filters['filter'])) {
            if ($filters['filter'] === 'unread') {
                $query->unread();
            } elseif ($filters['filter'] === 'read') {
                $query->whereNotNull('read_at');
            } elseif ($filters['filter'] === 'today') {
                $query->whereDate('created_at', today());
            }
        }

        $perPage = config('pagination.notifications', 20);

        return $query->recent()->paginate($perPage);
    }

    public function markAsRead(Notification $notification): void
    {
        if (!$notification->read_at) {
            $notification->update(['read_at' => now()]);
        }
    }

    public function markAllAsRead(User $user): void
    {
        $this->model->where('user_id', $user->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);
    }
}
