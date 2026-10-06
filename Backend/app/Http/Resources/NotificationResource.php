<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class NotificationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (string)$this->id,
            'user_id' => (string)$this->user_id,
            'title' => $this->title,
            'message' => $this->message,
            'type' => $this->type?->value,
            'is_read' => $this->read_at !== null,
            'read_at' => $this->read_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
            'reference' => $this->reference_id ? [
                'type' => class_basename($this->reference_type),
                'id' => (string)$this->reference_id,
            ] : null,
        ];
    }
}
