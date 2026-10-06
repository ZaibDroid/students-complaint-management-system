<?php

namespace App\Contracts\Services;

use App\Models\Notice;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Pagination\LengthAwarePaginator;

interface NoticeServiceInterface extends BaseServiceInterface
{
    public function createNotice(User $sender, array $data, array $targets = [], array $attachments = []): Notice;

    public function updateNotice(Notice $notice, array $data, ?array $targets = null, array $attachments = []): Notice;

    public function getNoticesForUser(User $user, array $filters = [], int $perPage = 15): LengthAwarePaginator;

    public function deleteAttachment(\App\Models\NoticeAttachment $attachment): void;
}
