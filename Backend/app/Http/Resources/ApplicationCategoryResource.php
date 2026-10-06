<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ApplicationCategoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (int)$this->id,
            'name' => $this->name,
            'slug' => $this->slug,
        ];
    }
}
