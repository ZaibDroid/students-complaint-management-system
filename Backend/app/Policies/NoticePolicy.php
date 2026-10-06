<?php

namespace App\Policies;

use App\Models\Notice;
use App\Models\User;

class NoticePolicy
{
    public function before(User $user, string $ability): ?bool
    {
        if ($user->hasRole('Admin')) {
            return true;
        }

        return null;
    }

    public function viewAny(User $user): bool
    {
        return true;
    }

    public function view(User $user, Notice $notice): bool
    {
        if ($user->hasRole('Student')) {
            return $notice->status === \App\Enums\NoticeStatus::Published;
        }

        return true;
    }

    public function create(User $user): bool
    {
        return $user->hasAnyRole(['Chairman', 'Batch Adviser', 'Coordinator', 'Office Staff', 'Dean']);
    }

    public function update(User $user, Notice $notice): bool
    {
        return $notice->sender_id === $user->id || $user->hasRole('Chairman');
    }

    public function delete(User $user, Notice $notice): bool
    {
        return $notice->sender_id === $user->id || $user->hasRole('Chairman');
    }
}
