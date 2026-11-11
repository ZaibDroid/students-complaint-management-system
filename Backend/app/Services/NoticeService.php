<?php

namespace App\Services;

use App\Contracts\Repositories\NoticeRepositoryInterface;
use App\Contracts\Repositories\NoticeTargetRepositoryInterface;
use App\Contracts\Services\NoticeServiceInterface;
use App\Contracts\Services\NoticePublishingServiceInterface;
use App\Enums\NoticeStatus;
use App\Models\Notice;
use App\Models\NoticeAttachment;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class NoticeService extends BaseService implements NoticeServiceInterface
{
    protected NoticeTargetRepositoryInterface $targetRepository;
    protected NoticePublishingServiceInterface $publishingService;

    public function __construct(
        NoticeRepositoryInterface $repository,
        NoticeTargetRepositoryInterface $targetRepository,
        NoticePublishingServiceInterface $publishingService
    ) {
        parent::__construct($repository);
        $this->targetRepository = $targetRepository;
        $this->publishingService = $publishingService;
    }

    public function createNotice(User $sender, array $data, array $targets = [], array $attachments = []): Notice
    {
        return DB::transaction(function () use ($sender, $data, $targets, $attachments) {
            $data['sender_id'] = $sender->id;
            
            // Extract intended status if provided, but default to Draft for creation
            $intendedStatus = $data['status'] ?? NoticeStatus::Draft->value;
            $data['status'] = NoticeStatus::Draft->value;
            
            // Versioning defaults to 1
            $data['version'] = 1;

            // Map legacy targets into normalized columns if not already provided
            foreach ($targets as $target) {
                $type = $target['type'] ?? '';
                $val = $target['value'] ?? null;
                if ($type === 'department_id' && is_numeric($val) && empty($data['department_id'])) {
                    $data['department_id'] = (int)$val;
                } elseif ($type === 'batch_id' && is_numeric($val) && empty($data['target_batch_id'])) {
                    $data['target_batch_id'] = (int)$val;
                } elseif ($type === 'section_id' && is_numeric($val) && empty($data['target_section_id'])) {
                    $data['target_section_id'] = (int)$val;
                } elseif ($type === 'crs_only' && empty($data['target_role'])) {
                    $data['target_role'] = 'CR';
                }
            }

            /** @var Notice $notice */
            $notice = $this->repository->create($data);

            // Save targets if table exists
            if (\Illuminate\Support\Facades\Schema::hasTable('notice_targets')) {
                foreach ($targets as $target) {
                    $this->targetRepository->create([
                        'notice_id' => $notice->id,
                        'target_type' => $target['type'],
                        'target_value' => $target['value'] ?? null,
                    ]);
                }
            }

            // Save attachments
            foreach ($attachments as $attachment) {
                $this->uploadAttachment($notice, $attachment);
            }

            // Handle status transitions if necessary
            $notice->refresh();
            if ($intendedStatus === NoticeStatus::Published->value) {
                $notice = $this->publishingService->publish($notice);
            } elseif ($intendedStatus === NoticeStatus::Scheduled->value && !empty($data['scheduled_at'])) {
                $notice = $this->publishingService->schedule($notice, new \DateTime($data['scheduled_at']));
            }

            $relationsToLoad = ['sender', 'attachments', 'targetBatch', 'targetSection', 'department'];
            if (\Illuminate\Support\Facades\Schema::hasTable('notice_targets')) {
                $relationsToLoad[] = 'targets';
            }

            return $notice->fresh($relationsToLoad);
        });
    }

    public function updateNotice(Notice $notice, array $data, ?array $targets = null, array $attachments = []): Notice
    {
        return DB::transaction(function () use ($notice, $data, $targets, $attachments) {
            
            // Version increment feature is deferred for now

            $intendedStatus = $data['status'] ?? null;
            unset($data['status']); // We handle status via publishing service

            $this->repository->update($notice->id, $data);

            if ($targets !== null && \Illuminate\Support\Facades\Schema::hasTable('notice_targets')) {
                $notice->targets()->delete();
                foreach ($targets as $target) {
                    $this->targetRepository->create([
                        'notice_id' => $notice->id,
                        'target_type' => $target['type'],
                        'target_value' => $target['value'] ?? null,
                    ]);
                }
            }

            // Upload new attachments
            foreach ($attachments as $attachment) {
                $this->uploadAttachment($notice, $attachment);
            }

            $notice->refresh();

            if ($intendedStatus) {
                if ($intendedStatus === NoticeStatus::Published->value && $notice->status !== NoticeStatus::Published) {
                    $notice = $this->publishingService->publish($notice);
                } elseif ($intendedStatus === NoticeStatus::Scheduled->value && !empty($data['scheduled_at'])) {
                    $notice = $this->publishingService->schedule($notice, new \DateTime($data['scheduled_at']));
                } elseif ($intendedStatus === NoticeStatus::Expired->value && $notice->status !== NoticeStatus::Expired) {
                    $notice = $this->publishingService->expire($notice);
                }
            }

            $relationsToLoad = ['sender', 'attachments', 'targetBatch', 'targetSection', 'department'];
            if (\Illuminate\Support\Facades\Schema::hasTable('notice_targets')) {
                $relationsToLoad[] = 'targets';
            }

            return $notice->fresh($relationsToLoad);
        });
    }

    public function getNoticesForUser(User $user, array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        /** @var NoticeRepositoryInterface $repo */
        $repo = $this->repository;
        return $repo->getNoticesForUser($user, $filters, $perPage);
    }

    protected function uploadAttachment(Notice $notice, UploadedFile $file): void
    {
        $path = $file->store('notices', 'public');
        
        $notice->attachments()->create([
            'file_name' => $file->getClientOriginalName(),
            'file_path' => $path,
            'file_type' => $file->getClientMimeType(),
            'file_size' => $file->getSize(),
        ]);
    }

    public function deleteAttachment(NoticeAttachment $attachment): void
    {
        DB::transaction(function () use ($attachment) {
            $filePath = $attachment->file_path;
            $attachment->delete();

            DB::afterCommit(function () use ($filePath) {
                Storage::disk('public')->delete($filePath);
            });
        });
    }
}
