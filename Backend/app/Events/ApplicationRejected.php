<?php

namespace App\Events;

use App\Models\Application;
use App\Models\User;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ApplicationRejected
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public Application $application;
    public User $actor;
    public ?User $targetUser;
    public ?string $notes;

    public function __construct(Application $application, User $actor, ?User $targetUser = null, ?string $notes = null)
    {
        $this->application = $application;
        $this->actor = $actor;
        $this->targetUser = $targetUser;
        $this->notes = $notes;
    }
}
