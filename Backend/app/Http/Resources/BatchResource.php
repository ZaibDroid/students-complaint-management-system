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

        return [
            'id' => (string)$this->id,
            'name' => $this->name,
            'sections' => $sectionsList,
            'section_details' => SectionResource::collection($this->whenLoaded('sections')),
            'start_year' => $this->start_year,
            'end_year' => $this->end_year,
            'is_active' => (bool)$this->is_active,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
