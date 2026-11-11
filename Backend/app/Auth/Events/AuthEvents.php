<?php

namespace App\Auth\Events;

use App\Models\User;
use App\Models\UserDevice;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class UserLoggedIn
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    public function __construct(public User $user) {}
}

class UserLoggedOut
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    public function __construct(public User $user) {}
}

class RefreshTokenUsed
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    public function __construct(public User $user, public UserDevice $device) {}
}

class DeviceRevoked
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    public function __construct(public UserDevice $device) {}
}

class FailedLogin
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    public function __construct(public string $identifier, public string $ip, public string $reason) {}
}

class PasswordReset
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    public function __construct(public User $user) {}
}
