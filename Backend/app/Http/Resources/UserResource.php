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

        $deptName = $this->department?->name ?? ($this->relationLoaded('department') ? $this->department?->name : null) ?? $this->batch?->department?->name ?? null;
        $batchName = $this->batch?->name ?? $this->batch_display;
        $sectionName = $this->section?->name ?? $this->section_display;

        if ($roleName === 'Batch Adviser' || $this->hasRole('Batch Adviser')) {
            if (empty($batchName) || $batchName === 'N/A') {
                $batchName = $assignedSectionsList[0]['batch'] ?? $batchName;
            }
            if (empty($sectionName) || $sectionName === 'N/A') {
                $sectionName = $assignedSectionsList[0]['section'] ?? $sectionName;
            }
        }

        $sectionAdviser = (!$this->adviser_id && $this->section) ? $this->section->assignedStaff?->first() : null;
        $adviserName = $this->adviser?->name ?? ($this->relationLoaded('adviser') ? $this->adviser?->name : null) ?? $sectionAdviser?->name;
        $adviserIdVal = $this->adviser_id ? (string)$this->adviser_id : ($sectionAdviser ? (string)$sectionAdviser->id : null);

        $yearStr = $this->year ?? ($this->current_semester ? "Semester {$this->current_semester}" : ($this->semester ?? null));
        $semesterStr = $this->semester ?? ($this->current_semester ? "Semester {$this->current_semester}" : null);

        $resolvedAssignedPassword = $this->assigned_password;
        if (!$resolvedAssignedPassword && $this->password) {
            foreach (['112233', '123456', 'Password123!', 'password', '12345678', 'admin123', 'admin', 'coordinator'] as $candidate) {
                if (\Illuminate\Support\Facades\Hash::check($candidate, $this->password)) {
                    $resolvedAssignedPassword = $candidate;
                    \Illuminate\Support\Facades\DB::table('users')->where('id', $this->id)->update(['assigned_password' => $candidate]);
                    break;
                }
            }
        }

        return [
            'id' => (string)$this->id,
            'name' => $this->name,
            'email' => $this->email,
            'role' => $roleName,
            'roles' => $this->getRoleNames(),
            'department_id' => $this->department_id ? (string)$this->department_id : null,
            'departmentId' => $this->department_id ? (string)$this->department_id : null,
            'department' => $deptName,
            'department_name' => $deptName,
            'departmentName' => $deptName,
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
            'batch_id' => $this->batch_id ? (string)$this->batch_id : null,
            'batchId' => $this->batch_id ? (string)$this->batch_id : null,
            'batch' => $batchName,
            'batch_details' => $this->whenLoaded('batch', function () {
                return [
                    'id' => $this->batch->id,
                    'name' => $this->batch->name,
                ];
            }),
            'section_id' => $this->section_id ? (string)$this->section_id : null,
            'sectionId' => $this->section_id ? (string)$this->section_id : null,
            'section' => $sectionName,
            'coordinated_batch_ids' => $this->hasRole('Coordinator') ? array_map('strval', $this->getAssignedBatchIds()) : [],
            'coordinated_batches' => $this->hasRole('Coordinator') ? $this->coordinatedBatches->map(fn($b) => [
                'id' => (string)$b->id,
                'name' => $b->name,
                'start_year' => $b->start_year,
                'end_year' => $b->end_year,
            ])->values()->all() : [],
            'section_details' => $this->whenLoaded('section', function () {
                return [
                    'id' => $this->section->id,
                    'name' => $this->section->name,
                ];
            }),
            'current_semester' => $this->current_semester,
            'currentSemester' => $this->current_semester,
            'year' => $yearStr,
            'semester' => $semesterStr,
            'adviser_id' => $adviserIdVal,
            'adviserId' => $adviserIdVal,
            'adviser' => $adviserName,
            'adviser_details' => $this->adviser ? [
                'id' => (string)$this->adviser->id,
                'name' => $this->adviser->name,
                'email' => $this->adviser->email,
            ] : ($sectionAdviser ? [
                'id' => (string)$sectionAdviser->id,
                'name' => $sectionAdviser->name,
                'email' => $sectionAdviser->email,
            ] : null),
            'is_cr' => (bool)$this->is_cr,
            'isCR' => (bool)$this->is_cr,
            'status' => $this->status,
            'phone' => $this->phone,
            'profile_image_url' => $this->profile_image_url,
            'profileImageUrl' => $this->profile_image_url,
            'assigned_sections' => $assignedSectionsList,
            'assignedSections' => $assignedSectionsList,
            'assigned_password' => ($this->hasRole('Student') || $roleName === 'Student') ? null : ($resolvedAssignedPassword ?: $this->assigned_password),
            'assignedPassword' => ($this->hasRole('Student') || $roleName === 'Student') ? null : ($resolvedAssignedPassword ?: $this->assigned_password),
            'created_at' => $this->created_at?->toIso8601String(),
            'createdAt' => $this->created_at?->toIso8601String(),
        ];
    }
}
