<?php

namespace App\Auth\Events;

use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class FailedLogin
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    public function __construct(public string $identifier, public string $ip, public string $reason) {}
}
