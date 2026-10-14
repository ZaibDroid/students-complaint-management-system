<?php

namespace App\Auth\Events;

use App\Models\User;
use App\Models\UserDevice;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class RefreshTokenUsed
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    public function __construct(public User $user, public UserDevice $device) {}
}
