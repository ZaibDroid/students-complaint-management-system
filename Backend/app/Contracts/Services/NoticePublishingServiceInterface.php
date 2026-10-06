<?php

namespace App\Contracts\Services;

use App\Models\Notice;

interface NoticePublishingServiceInterface
{
    public function publish(Notice $notice): Notice;
    public function expire(Notice $notice): Notice;
    public function schedule(Notice $notice, \DateTimeInterface $scheduledAt): Notice;
}
