<?php

namespace App\Listeners;

use App\Contracts\Repositories\ApplicationTimelineRepositoryInterface;
use App\Events\ApplicationForwarded;
use App\Events\ApplicationRejected;
use App\Events\ApplicationResolved;
use App\Events\ApplicationReturned;
use App\Events\ApplicationSubmitted;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class CreateTimelineEntry implements ShouldQueue
{
    use InteractsWithQueue;
    protected ApplicationTimelineRepositoryInterface $timelineRepository;

    public function __construct(ApplicationTimelineRepositoryInterface $timelineRepository)
    {
        $this->timelineRepository = $timelineRepository;
    }

    public function handle($event): void
    {
        $application = $event->Application;
        $actor = $event->actor;
        $targetUser = $event->targetUser;
        $notes = $event->notes;

        $actorRole = $actor->getRoleNames()->first() ?? 'Staff';
        $targetRole = $targetUser ? ($targetUser->getRoleNames()->first() ?? 'Staff') : null;

        $action = 'Updated';
        if ($event instanceof ApplicationSubmitted) $action = 'Submitted';
        elseif ($event instanceof ApplicationForwarded) $action = 'Forwarded';
        elseif ($event instanceof ApplicationResolved) $action = 'Resolved';
        elseif ($event instanceof ApplicationRejected) $action = 'Rejected';
        elseif ($event instanceof ApplicationReturned) $action = 'Returned';

        if (!$notes) {
            $notes = "Application status updated to " . strtolower($action);
        }

        // Idempotency check: prevent duplicate timeline entries
        $exists = $this->timelineRepository->model()
            ->where('application_id', $application->id)
            ->where('action', $action)
            ->where('from_user_id', $actor->id)
            ->where('created_at', '>=', now()->subSeconds(10))
            ->exists();

        if ($exists) {
            return;
        }

        $this->timelineRepository->create([
            'application_id' => $application->id,
            'from_user_id' => $actor->id,
            'to_user_id' => $targetUser ? $targetUser->id : null,
            'from_role' => $actorRole,
            'to_role' => $targetRole,
            'action' => $action,
            'notes' => $notes,
        ]);
    }
}
