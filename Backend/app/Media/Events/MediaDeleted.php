<?php

namespace App\Media\Events;

use App\Models\Media;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MediaDeleted
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public Media $media)
    {
    }
}
