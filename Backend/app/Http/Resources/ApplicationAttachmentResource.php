<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ApplicationAttachmentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'file_path' => $this->file_path,
            'file_name' => $this->file_name,
            'file_type' => $this->file_type,
            'file_size' => $this->file_size,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
