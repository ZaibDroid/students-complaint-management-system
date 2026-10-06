<?php

namespace App\Media\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\URL;

class MediaResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'extension' => $this->extension,
            'mime_type' => $this->mime_type,
            'size' => $this->size,
            'download_url' => $this->download_url, // Calls getter on model
            'preview_url' => null, // Reserved for future image thumbnails
            'uploaded_at' => $this->created_at->toIso8601String(),
            'uploaded_by' => $this->whenLoaded('uploader', function () {
                return [
                    'id' => $this->uploader->id,
                    'name' => $this->uploader->name,
                ];
            }),
        ];
    }
}
