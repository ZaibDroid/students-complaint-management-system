<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ApplicationRemarkResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $authorUser = $this->relationLoaded('user') ? $this->user : $this->user()->first();
        $authorName = $authorUser?->name ?? 'Staff';
        $authorRole = $authorUser ? ($authorUser->getRoleNames()->first() ?? 'Staff') : 'Staff';

        return [
            'id' => (string)$this->id,
            'remark' => $this->remark,
            'action_taken' => $this->action_taken ?? 'Remark Added',
            'actionTaken' => $this->action_taken ?? 'Remark Added',
            'author_name' => $authorName,
            'authorName' => $authorName,
            'author_role' => $authorRole,
            'authorRole' => $authorRole,
            'author' => $authorUser ? new UserResource($authorUser) : null,
            'created_at' => $this->created_at?->toIso8601String(),
            'createdAt' => $this->created_at?->toIso8601String(),
        ];
    }
}
