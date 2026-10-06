<?php

namespace App\Http\Requests\Section;

use App\Http\Requests\BaseApiRequest;

class CreateSectionRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'batch_id' => ['required', 'exists:batches,id'],
            'name' => ['required', 'string', 'max:255'],
            'is_active' => ['nullable', 'boolean'],
        ];
    }
}
