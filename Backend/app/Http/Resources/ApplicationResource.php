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

        $involvedStaffNames = collect([]);
        if ($this->relationLoaded('timeline') && $this->timeline) {
            foreach ($this->timeline as $tl) {
                if ($tl->fromUser?->name) $involvedStaffNames->push($tl->fromUser->name);
                if ($tl->toUser?->name) $involvedStaffNames->push($tl->toUser->name);
            }
        } elseif ($this->timeline()->exists()) {
            $timelines = $this->timeline()->with(['fromUser', 'toUser'])->get();
            foreach ($timelines as $tl) {
                if ($tl->fromUser?->name) $involvedStaffNames->push($tl->fromUser->name);
                if ($tl->toUser?->name) $involvedStaffNames->push($tl->toUser->name);
            }
        }

        if ($this->relationLoaded('remarks') && $this->remarks) {
            foreach ($this->remarks as $rem) {
                if ($rem->user?->name) $involvedStaffNames->push($rem->user->name);
            }
        } elseif ($this->remarks()->exists()) {
            $remarks = $this->remarks()->with('user')->get();
            foreach ($remarks as $rem) {
                if ($rem->user?->name) $involvedStaffNames->push($rem->user->name);
            }
        }

        if ($this->student?->adviser?->name) {
            $involvedStaffNames->push($this->student->adviser->name);
        }

        $involvedStaffNamesList = $involvedStaffNames->filter()->unique()->values()->all();

        $assignedCoordinator = $this->getAssignedCoordinator();
        $studentBatchId = $this->student?->batch_id ?: $this->student?->section?->batch_id;

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
            'assigned_coordinator_id' => $assignedCoordinator ? (string)$assignedCoordinator->id : null,
            'assigned_coordinator_name' => $assignedCoordinator?->name,
            'assignedCoordinatorId' => $assignedCoordinator ? (string)$assignedCoordinator->id : null,
            'assignedCoordinatorName' => $assignedCoordinator?->name,
            'student_batch_id' => $studentBatchId ? (string)$studentBatchId : null,
            'studentBatchId' => $studentBatchId ? (string)$studentBatchId : null,
            'student_batch' => $this->student?->batch?->name,
            'studentBatch' => $this->student?->batch?->name,
            'student_section' => $this->student?->section?->name,
            'studentSection' => $this->student?->section?->name,
            'involved_staff_names' => $involvedStaffNamesList,
            'involvedStaffNames' => $involvedStaffNamesList,
            'student' => $this->whenLoaded('student', fn() => new UserResource($this->student)),
            'assigned_to_user' => $this->whenLoaded('assignedTo', fn() => new UserResource($this->assignedTo)),
            'attachments' => $attachmentUrls,
            'remarks' => $remarksList,
            'timeline' => $this->whenLoaded('timeline', fn() => ApplicationTimelineResource::collection($this->timeline)),
            'created_at' => $this->created_at?->toIso8601String(),
            'createdAt' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
            'updatedAt' => $this->updated_at?->toIso8601String(),
        ];
    }
}
