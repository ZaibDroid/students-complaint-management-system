<?php

namespace App\Services;

use App\Contracts\Repositories\NoticeRepositoryInterface;
use App\Contracts\Services\NoticePublishingServiceInterface;
use App\Enums\NoticeStatus;
use App\Events\NoticePublished;
use App\Models\Notice;
use Illuminate\Support\Facades\DB;

class NoticePublishingService implements NoticePublishingServiceInterface
{
    protected NoticeRepositoryInterface $repository;

    public function __construct(NoticeRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function publish(Notice $notice): Notice
    {
        return DB::transaction(function () use ($notice) {
            $lockedNotice = $this->repository->lockForUpdate($notice->id);

            if ($lockedNotice->status === NoticeStatus::Published) {
                return $lockedNotice;
            }

            $this->repository->update($lockedNotice->id, [
                'status' => NoticeStatus::Published,
                'published_at' => now(),
            ]);

            $lockedNotice->refresh();

            DB::afterCommit(function () use ($lockedNotice) {
                event(new NoticePublished($lockedNotice));
            });

            return $lockedNotice;
        });
    }

    public function expire(Notice $notice): Notice
    {
        return DB::transaction(function () use ($notice) {
            $lockedNotice = $this->repository->lockForUpdate($notice->id);

            if ($lockedNotice->status === NoticeStatus::Expired) {
                return $lockedNotice;
            }

            $this->repository->update($lockedNotice->id, [
                'status' => NoticeStatus::Expired,
            ]);

            return $lockedNotice->refresh();
        });
    }

    public function schedule(Notice $notice, \DateTimeInterface $scheduledAt): Notice
    {
        return DB::transaction(function () use ($notice, $scheduledAt) {
            $lockedNotice = $this->repository->lockForUpdate($notice->id);

            $this->repository->update($lockedNotice->id, [
                'status' => NoticeStatus::Scheduled,
                'scheduled_at' => $scheduledAt,
            ]);

            return $lockedNotice->refresh();
        });
    }
}
