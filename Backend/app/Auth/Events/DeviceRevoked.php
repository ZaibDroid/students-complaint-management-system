<?php

namespace App\Auth\Events;

use App\Models\UserDevice;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class DeviceRevoked
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    public function __construct(public UserDevice $device) {}
}
