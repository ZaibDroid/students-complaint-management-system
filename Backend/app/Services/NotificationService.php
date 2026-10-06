<?php

namespace App\Services;

use App\Contracts\Services\NotificationServiceInterface;
use App\Contracts\Channels\NotificationChannelInterface;
use App\Models\User;
use App\Models\Application;
use App\Models\Notice;
use Illuminate\Database\Eloquent\Model;
use App\Enums\NotificationType;

class NotificationService implements NotificationServiceInterface
{
    /** @var NotificationChannelInterface[] */
    protected array $channels;

    public function __construct(\App\Channels\DatabaseNotificationChannel $databaseChannel)
    {
        // For now, we manually register the Database channel. 
        // In the future, this can be resolved via a Provider.
        $this->channels = [
            $databaseChannel
        ];
    }

    protected function send(User $user, NotificationType $type, string $title, string $message, ?Model $reference = null): void
    {
        foreach ($this->channels as $channel) {
            $channel->send($user, $type, $title, $message, $reference);
        }
    }

    public function sendApplicationNotification(User $user, NotificationType $type, Application $application, string $title, string $message): void
    {
        $this->send($user, $type, $title, $message, $application);
    }

    public function sendNoticeNotification(User $user, Notice $notice, string $title, string $message): void
    {
        $this->send($user, NotificationType::NoticePublished, $title, $message, $notice);
    }

    public function sendSystemNotification(User $user, string $title, string $message): void
    {
        $this->send($user, NotificationType::SystemAnnouncement, $title, $message, null);
    }

    public function sendToRole(string $role, NotificationType $type, string $title, string $message, ?Model $reference = null): void
    {
        User::role($role)->chunk(100, function ($users) use ($type, $title, $message, $reference) {
            foreach ($users as $user) {
                $this->send($user, $type, $title, $message, $reference);
            }
        });
    }

    public function sendToDepartment(int $departmentId, NotificationType $type, string $title, string $message, ?Model $reference = null): void
    {
        User::where('department_id', $departmentId)->chunk(100, function ($users) use ($type, $title, $message, $reference) {
            foreach ($users as $user) {
                $this->send($user, $type, $title, $message, $reference);
            }
        });
    }

    public function sendToBatch(int $batchId, NotificationType $type, string $title, string $message, ?Model $reference = null): void
    {
        User::whereHas('studentProfile', function ($query) use ($batchId) {
            $query->where('batch_id', $batchId);
        })->chunk(100, function ($users) use ($type, $title, $message, $reference) {
            foreach ($users as $user) {
                $this->send($user, $type, $title, $message, $reference);
            }
        });
    }

    public function sendToSection(int $sectionId, NotificationType $type, string $title, string $message, ?Model $reference = null): void
    {
        User::whereHas('studentProfile', function ($query) use ($sectionId) {
            $query->where('section_id', $sectionId);
        })->chunk(100, function ($users) use ($type, $title, $message, $reference) {
            foreach ($users as $user) {
                $this->send($user, $type, $title, $message, $reference);
            }
        });
    }
}
