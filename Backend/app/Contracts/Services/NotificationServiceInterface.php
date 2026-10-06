<?php

namespace App\Contracts\Services;

use App\Models\User;
use App\Models\Application;
use App\Models\Notice;
use Illuminate\Database\Eloquent\Model;
use App\Enums\NotificationType;

interface NotificationServiceInterface
{
    public function sendApplicationNotification(User $user, NotificationType $type, Application $application, string $title, string $message): void;

    public function sendNoticeNotification(User $user, Notice $notice, string $title, string $message): void;

    public function sendSystemNotification(User $user, string $title, string $message): void;

    // Helper methods for targeting
    public function sendToRole(string $role, NotificationType $type, string $title, string $message, ?Model $reference = null): void;
    
    public function sendToDepartment(int $departmentId, NotificationType $type, string $title, string $message, ?Model $reference = null): void;
    
    public function sendToBatch(int $batchId, NotificationType $type, string $title, string $message, ?Model $reference = null): void;
    
    public function sendToSection(int $sectionId, NotificationType $type, string $title, string $message, ?Model $reference = null): void;
}
