<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BatchResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $sectionsList = $this->relationLoaded('sections')
            ? $this->sections->pluck('name')->toArray()
            : [];

        $user = $request->user() ?? auth('sanctum')->user();
        $isStaff = $user && $user->hasAnyRole(['Chairman', 'Admin', 'Department Office', 'Coordinator', 'Batch Advisor', 'Batch Adviser']);

        $data = [
            'id' => (string)$this->id,
            'name' => $this->name,
            'sections' => $sectionsList,
            'section_details' => SectionResource::collection($this->whenLoaded('sections')),
            'start_year' => $this->start_year,
            'end_year' => $this->end_year,
            'department_id' => $this->department_id ? (string)$this->department_id : null,
            'is_active' => (bool)$this->is_active,
            'created_at' => $this->created_at?->toIso8601String(),
        ];

        if ($isStaff) {
            $data['coordinator_id'] = $this->coordinator_id ? (string)$this->coordinator_id : null;
            $data['coordinator_name'] = $this->relationLoaded('coordinator') && $this->coordinator ? $this->coordinator->name : ($this->coordinator?->name);
            $data['is_coordinator_assigned'] = !empty($this->coordinator_id);
        }

        return $data;
    }
}
