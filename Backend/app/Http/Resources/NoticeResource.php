<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class NoticeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $senderName = $this->sender?->name ?? '';
        return [
            'id' => (string)$this->id,
            'title' => $this->title,
            'description' => $this->description,
            'sender_id' => (string)$this->sender_id,
            'senderId' => (string)$this->sender_id,
            'sender_name' => $senderName,
            'senderName' => $senderName,
            'sender' => new UserResource($this->whenLoaded('sender')),
            'department_id' => $this->department_id ? (string)$this->department_id : null,
            'target_batch_id' => $this->target_batch_id ? (string)$this->target_batch_id : null,
            'target_section_id' => $this->target_section_id ? (string)$this->target_section_id : null,
            'target_role' => $this->target_role,
            'target_year' => $this->getTargetValue('year'),
            'targetYear' => $this->getTargetValue('year'),
            'target_batches' => $this->target_batch_id ? [(string)$this->target_batch_id] : $this->getTargetValues('batch'),
            'targetBatches' => $this->target_batch_id ? [(string)$this->target_batch_id] : $this->getTargetValues('batch'),
            'target_sections' => $this->target_section_id ? [(string)$this->target_section_id] : $this->getTargetValues('section'),
            'targetSections' => $this->target_section_id ? [(string)$this->target_section_id] : $this->getTargetValues('section'),
            'target_roles' => $this->target_role ? [$this->target_role] : $this->getTargetValues('role'),
            'targetRoles' => $this->target_role ? [$this->target_role] : $this->getTargetValues('role'),
            'target_crs_only' => ($this->target_role === 'CR') || ($this->getTargetValue('crs_only') === 'true'),
            'targetCRsOnly' => ($this->target_role === 'CR') || ($this->getTargetValue('crs_only') === 'true'),
            'tag' => $this->tag,
            'status' => $this->status,
            'version' => $this->version,
            'published_at' => $this->published_at,
            'scheduled_at' => $this->scheduled_at,
            'expires_at' => $this->expires_at,
            'attachments' => $this->whenLoaded('attachments', function () {
                return $this->attachments->map(function ($attachment) {
                    return [
                        'id' => $attachment->id,
                        'file_name' => $attachment->file_name,
                        'file_url' => asset('storage/' . $attachment->file_path),
                        'file_type' => $attachment->file_type,
                        'file_size' => $attachment->file_size,
                    ];
                });
            }),
            'targets' => NoticeTargetResource::collection($this->whenLoaded('targets')),
            'created_at' => $this->created_at?->toIso8601String(),
            'createdAt' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
            'updatedAt' => $this->updated_at?->toIso8601String(),
        ];
    }
}
