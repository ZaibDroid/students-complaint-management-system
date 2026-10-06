<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $roleName = $this->getRoleNames()->first() ?? 'Student';
        $assignedSectionsList = null;
        if ($this->relationLoaded('assignedSections') && $this->assignedSections->isNotEmpty()) {
            $assignedSectionsList = $this->assignedSections->map(function ($sec) {
                return [
                    'id' => (string)$sec->id,
                    'name' => $sec->name,
                    'batch' => $sec->batch?->name,
                    'section' => $sec->name,
                ];
            })->toArray();
        } elseif ($this->section) {
            $assignedSectionsList = [[
                'id' => (string)$this->section->id,
                'name' => $this->section->name,
                'batch' => $this->batch?->name,
                'section' => $this->section->name,
            ]];
        }

        return [
            'id' => (string)$this->id,
            'name' => $this->name,
            'email' => $this->email,
            'role' => $roleName,
            'roles' => $this->getRoleNames(),
            'department' => $this->department?->name ?? ($this->relationLoaded('department') ? $this->department?->name : null),
            'department_details' => $this->whenLoaded('department', function () {
                return [
                    'id' => $this->department->id,
                    'name' => $this->department->name,
                    'code' => $this->department->code,
                ];
            }),
            'registration_number' => $this->registration_number,
            'registrationNumber' => $this->registration_number,
            'reg_no' => $this->registration_number,
            'batch' => $this->batch?->name ?? $this->batch_display,
            'batch_details' => $this->whenLoaded('batch', function () {
                return [
                    'id' => $this->batch->id,
                    'name' => $this->batch->name,
                ];
            }),
            'section' => $this->section?->name ?? $this->section_display,
            'section_details' => $this->whenLoaded('section', function () {
                return [
                    'id' => $this->section->id,
                    'name' => $this->section->name,
                ];
            }),
            'year' => $this->year,
            'semester' => $this->semester,
            'adviser' => $this->adviser?->name ?? ($this->relationLoaded('adviser') ? $this->adviser?->name : null),
            'adviser_details' => $this->whenLoaded('adviser', function () {
                return [
                    'id' => $this->adviser->id,
                    'name' => $this->adviser->name,
                    'email' => $this->adviser->email,
                ];
            }),
            'is_cr' => (bool)$this->is_cr,
            'isCR' => (bool)$this->is_cr,
            'status' => $this->status,
            'phone' => $this->phone,
            'profile_image_url' => $this->profile_image_url,
            'profileImageUrl' => $this->profile_image_url,
            'assigned_sections' => $assignedSectionsList,
            'assignedSections' => $assignedSectionsList,
            'created_at' => $this->created_at?->toIso8601String(),
            'createdAt' => $this->created_at?->toIso8601String(),
        ];
    }
}
