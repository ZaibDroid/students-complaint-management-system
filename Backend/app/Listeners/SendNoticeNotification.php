<?php

namespace App\Listeners;

use App\Contracts\Services\NotificationServiceInterface;
use App\Enums\NotificationType;
use App\Events\NoticePublished;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\DB;

class SendNoticeNotification implements ShouldQueue
{
    use InteractsWithQueue;
    protected NotificationServiceInterface $notificationService;

    public function __construct(NotificationServiceInterface $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    public function handle(NoticePublished $event): void
    {
        $notice = $event->notice;
        $sender = $notice->sender;

        $title = 'New Notice Announcement';
        $message = "{$sender->name} published a new notice: {$notice->title}";
        
        DB::afterCommit(function () use ($notice, $title, $message) {
            // 1. Normalized targeting columns
            if (!empty($notice->target_role)) {
                $role = $notice->target_role === 'CR' ? 'Class Representative' : $notice->target_role;
                $this->notificationService->sendToRole($role, NotificationType::NoticePublished, $title, $message, $notice);
            } elseif (!empty($notice->target_section_id)) {
                $this->notificationService->sendToSection($notice->target_section_id, NotificationType::NoticePublished, $title, $message, $notice);
            } elseif (!empty($notice->target_batch_id)) {
                $this->notificationService->sendToBatch($notice->target_batch_id, NotificationType::NoticePublished, $title, $message, $notice);
            } elseif (!empty($notice->department_id)) {
                $this->notificationService->sendToDepartment($notice->department_id, NotificationType::NoticePublished, $title, $message, $notice);
            } else {
                $this->notificationService->sendToRole('Student', NotificationType::NoticePublished, $title, $message, $notice);
            }

            // 2. Legacy fallback if notice_targets table exists
            if (\Illuminate\Support\Facades\Schema::hasTable('notice_targets') && $notice->relationLoaded('targets')) {
                foreach ($notice->targets as $target) {
                    if ($target->target_type === 'all_students') {
                        $this->notificationService->sendToRole('Student', NotificationType::NoticePublished, $title, $message, $notice);
                    } elseif ($target->target_type === 'all_staff') {
                        $this->notificationService->sendToRole('Office Staff', NotificationType::NoticePublished, $title, $message, $notice);
                    } elseif ($target->target_type === 'batch_id' && !empty($target->target_value)) {
                        $this->notificationService->sendToBatch((int)$target->target_value, NotificationType::NoticePublished, $title, $message, $notice);
                    } elseif ($target->target_type === 'section_id' && !empty($target->target_value)) {
                        $this->notificationService->sendToSection((int)$target->target_value, NotificationType::NoticePublished, $title, $message, $notice);
                    } elseif ($target->target_type === 'department_id' && !empty($target->target_value)) {
                        $this->notificationService->sendToDepartment((int)$target->target_value, NotificationType::NoticePublished, $title, $message, $notice);
                    } elseif ($target->target_type === 'crs_only') {
                        $this->notificationService->sendToRole('Class Representative', NotificationType::NoticePublished, $title, $message, $notice);
                    }
                }
            }
        });
    }
}
