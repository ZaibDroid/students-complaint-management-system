<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ApplicationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $attachmentUrls = [];
        $attachments = $this->relationLoaded('attachments')
            ? $this->attachments
            : ($this->attachments()->exists() ? $this->attachments()->get() : collect([]));

        if ($attachments->isNotEmpty()) {
            foreach ($attachments as $att) {
                $attachmentUrls[] = $att->url;
            }
        } elseif (!empty($this->attachment_path)) {
            $attachmentUrls[] = str_starts_with($this->attachment_path, 'http')
                ? $this->attachment_path
                : asset('storage/' . ltrim($this->attachment_path, '/'));
        }

        $remarksList = $this->relationLoaded('remarks')
            ? ApplicationRemarkResource::collection($this->remarks)->toArray($request)
            : ($this->remarks()->exists()
                ? ApplicationRemarkResource::collection($this->remarks()->with('user')->get())->toArray($request)
                : []);

        $adminRemarks = $this->admin_remarks;
        if (empty($adminRemarks)) {
            if ($this->relationLoaded('remarks') && $this->remarks->isNotEmpty()) {
                $adminRemarks = $this->remarks->last()?->remark;
            } elseif ($this->remarks()->exists()) {
                $adminRemarks = $this->remarks()->latest('id')->value('remark');
            }
        }

        $studentName = $this->student?->name ?? 'Unknown';
        $assignedToName = $this->assignedTo?->name;
        $deptName = $this->department?->name ?? $this->student?->department?->name;

        return [
            'id' => (string)$this->id,
            'ticket_number' => $this->ticket_number,
            'department_id' => $this->department_id ? (string)$this->department_id : null,
            'departmentId' => $this->department_id ? (string)$this->department_id : null,
            'department_name' => $deptName,
            'departmentName' => $deptName,
            'student_id' => (string)$this->student_id,
            'studentId' => (string)$this->student_id,
            'student_name' => $studentName,
            'studentName' => $studentName,
            'title' => $this->title,
            'description' => $this->description,
            'category' => $this->category?->name ?? 'Uncategorized',
            'status' => $this->status,
            'priority' => $this->priority,
            'admin_remarks' => $adminRemarks,
            'adminRemarks' => $adminRemarks,
            'assigned_to' => $assignedToName,
            'assignedTo' => $assignedToName,
            'assigned_to_id' => $this->assigned_to_id ? (string)$this->assigned_to_id : null,
            'assignedToId' => $this->assigned_to_id ? (string)$this->assigned_to_id : null,
            'student_batch' => $this->student?->batch?->name,
            'studentBatch' => $this->student?->batch?->name,
            'student' => new UserResource($this->whenLoaded('student')),
            'assigned_to_user' => new UserResource($this->whenLoaded('assignedTo')),
            'attachments' => $attachmentUrls,
            'remarks' => $remarksList,
            'timeline' => ApplicationTimelineResource::collection($this->whenLoaded('timeline')),
            'created_at' => $this->created_at?->toIso8601String(),
            'createdAt' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
            'updatedAt' => $this->updated_at?->toIso8601String(),
        ];
    }
}
