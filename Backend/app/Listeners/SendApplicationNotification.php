<?php

namespace App\Listeners;

use App\Contracts\Services\NotificationServiceInterface;
use App\Enums\NotificationType;
use App\Events\ApplicationForwarded;
use App\Events\ApplicationRejected;
use App\Events\ApplicationResolved;
use App\Events\ApplicationReturned;
use App\Events\ApplicationSubmitted;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\DB;

class SendApplicationNotification implements ShouldQueue
{
    use InteractsWithQueue;
    protected NotificationServiceInterface $notificationService;

    public function __construct(NotificationServiceInterface $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    public function handle($event): void
    {
        $application = $event->Application;
        $actor = $event->actor;
        $targetUser = $event->targetUser;

        DB::afterCommit(function () use ($event, $application, $actor, $targetUser) {
            if ($event instanceof ApplicationSubmitted) {
                if ($targetUser) {
                    $this->notificationService->sendApplicationNotification(
                        $targetUser,
                        NotificationType::ApplicationSubmitted,
                        $application,
                        'New Application Submitted',
                        "Application {$application->ticket_number} submitted by {$actor->name}."
                    );
                }
            } elseif ($event instanceof ApplicationForwarded) {
                // Notify target user it was forwarded to them
                if ($targetUser) {
                    $this->notificationService->sendApplicationNotification(
                        $targetUser,
                        NotificationType::ApplicationForwarded,
                        $application,
                        'Application Forwarded',
                        "Application {$application->ticket_number} has been forwarded to you."
                    );
                }
                // Notify student
                $this->notificationService->sendApplicationNotification(
                    $application->student,
                    NotificationType::ApplicationForwarded,
                    $application,
                    'Application Status Updated',
                    "Your Application {$application->ticket_number} has been forwarded."
                );
            } elseif ($event instanceof ApplicationResolved) {
                $this->notificationService->sendApplicationNotification(
                    $application->student,
                    NotificationType::ApplicationResolved,
                    $application,
                    'Application Resolved',
                    "Your Application {$application->ticket_number} has been resolved."
                );
            } elseif ($event instanceof ApplicationRejected) {
                $this->notificationService->sendApplicationNotification(
                    $application->student,
                    NotificationType::ApplicationRejected,
                    $application,
                    'Application Rejected',
                    "Your Application {$application->ticket_number} has been rejected."
                );
            } elseif ($event instanceof ApplicationReturned) {
                $this->notificationService->sendApplicationNotification(
                    $application->student,
                    NotificationType::ApplicationReturned,
                    $application,
                    'Application Returned',
                    "Your Application {$application->ticket_number} has been returned for updates."
                );
            }
        });
    }
}
