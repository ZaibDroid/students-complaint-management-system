<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ApplicationRemarkResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'remark' => $this->remark,
            'action_taken' => $this->action_taken,
            'author' => new UserResource($this->whenLoaded('user')),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
