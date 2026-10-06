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
            'target_year' => $this->getTargetValue('year'),
            'targetYear' => $this->getTargetValue('year'),
            'target_batches' => $this->getTargetValues('batch'),
            'targetBatches' => $this->getTargetValues('batch'),
            'target_sections' => $this->getTargetValues('section'),
            'targetSections' => $this->getTargetValues('section'),
            'target_roles' => $this->getTargetValues('role'),
            'targetRoles' => $this->getTargetValues('role'),
            'target_crs_only' => $this->getTargetValue('crs_only') === 'true',
            'targetCRsOnly' => $this->getTargetValue('crs_only') === 'true',
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
