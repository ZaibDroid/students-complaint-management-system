<?php

namespace App\Audit\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AuditResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user' => $this->relationLoaded('user') && $this->user ? [
                'id' => $this->user->id,
                'name' => $this->user->name,
                'email' => $this->user->email,
            ] : null,
            'action' => $this->action,
            'model_type' => class_basename($this->model_type),
            'model_id' => $this->model_id,
            'old_values' => $this->old_values,
            'new_values' => $this->new_values,
            'ip' => $this->ip,
            'created_at' => $this->created_at->toIso8601String(),
        ];
    }
}
