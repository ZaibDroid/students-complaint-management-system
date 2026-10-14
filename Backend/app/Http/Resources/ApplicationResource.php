<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ApplicationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $attachmentUrls = [];
        if ($this->attachment_path) {
            $attachmentUrls[] = asset('storage/' . $this->attachment_path);
        }

        $remarksList = $this->relationLoaded('remarks')
            ? ApplicationRemarkResource::collection($this->remarks)->toArray($request)
            : [];

        $studentName = $this->student?->name ?? 'Unknown';
        $assignedToName = $this->assignedTo?->name;

        $involvedStaffNames = [];
        if ($this->relationLoaded('timeline') && $this->timeline) {
            foreach ($this->timeline as $t) {
                if ($t->fromUser && !in_array($t->fromUser->name, $involvedStaffNames)) {
                    $involvedStaffNames[] = $t->fromUser->name;
                }
                if ($t->toUser && !in_array($t->toUser->name, $involvedStaffNames)) {
                    $involvedStaffNames[] = $t->toUser->name;
                }
            }
        }
        if ($assignedToName && !in_array($assignedToName, $involvedStaffNames)) {
            $involvedStaffNames[] = $assignedToName;
        }

        return [
            'id' => (string)$this->id,
            'ticket_number' => $this->ticket_number,
            'student_id' => (string)$this->student_id,
            'studentId' => (string)$this->student_id,
            'student_name' => $studentName,
            'studentName' => $studentName,
            'title' => $this->title,
            'description' => $this->description,
            'category' => $this->category?->name ?? 'Uncategorized',
            'status' => $this->status,
            'priority' => $this->priority,
            'admin_remarks' => $this->admin_remarks,
            'adminRemarks' => $this->admin_remarks,
            'assigned_to' => $assignedToName,
            'assignedTo' => $assignedToName,
            'assigned_to_id' => $this->assigned_to_id ? (string)$this->assigned_to_id : null,
            'assignedToId' => $this->assigned_to_id ? (string)$this->assigned_to_id : null,
            'involved_staff_names' => $involvedStaffNames,
            'involvedStaffNames' => $involvedStaffNames,
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
