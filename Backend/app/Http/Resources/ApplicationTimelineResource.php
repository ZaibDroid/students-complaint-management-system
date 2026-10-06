<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ApplicationTimelineResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'action' => $this->action,
            'notes' => $this->notes,
            'from_role' => $this->from_role,
            'to_role' => $this->to_role,
            'from_user' => new UserResource($this->whenLoaded('fromUser')),
            'to_user' => new UserResource($this->whenLoaded('toUser')),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
