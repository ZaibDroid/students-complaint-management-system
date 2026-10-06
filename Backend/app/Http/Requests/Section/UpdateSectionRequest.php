<?php

namespace App\Http\Requests\Section;

use App\Http\Requests\BaseApiRequest;

class UpdateSectionRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'batch_id' => ['sometimes', 'exists:batches,id'],
            'name' => ['sometimes', 'string', 'max:255'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
