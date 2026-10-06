<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\BaseApiRequest;

class UpdateProfileRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:20'],
            'year' => ['sometimes', 'nullable', 'string'],
            'semester' => ['sometimes', 'nullable', 'string'],
            'batch' => ['sometimes', 'nullable', 'string'],
            'section' => ['sometimes', 'nullable', 'string'],
            'department' => ['sometimes', 'nullable', 'string'],
            'batch_id' => ['sometimes', 'nullable', 'exists:batches,id'],
            'section_id' => ['sometimes', 'nullable', 'exists:sections,id'],
            'department_id' => ['sometimes', 'nullable', 'exists:departments,id'],
        ];
    }
}
