<?php

namespace App\Http\Requests\User;

use App\Http\Requests\BaseApiRequest;

class AssignSectionsRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'section_ids' => ['required', 'array'],
            'section_ids.*' => ['exists:sections,id'],
        ];
    }
}
