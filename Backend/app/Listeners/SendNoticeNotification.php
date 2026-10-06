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
        });
    }
}
