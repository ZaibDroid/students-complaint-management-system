<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SectionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $user = $request->user() ?? auth('sanctum')->user();
        $isStaff = $user && $user->hasAnyRole(['Chairman', 'Admin', 'Department Office', 'Coordinator', 'Batch Advisor', 'Batch Adviser']);

        return [
            'id' => $this->id,
            'batch_id' => $this->batch_id,
            'name' => $this->name,
            'is_active' => (bool)$this->is_active,
            'batch' => new BatchResource($this->whenLoaded('batch')),
            'assigned_staff' => $isStaff ? UserResource::collection($this->whenLoaded('assignedStaff')) : [],
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
