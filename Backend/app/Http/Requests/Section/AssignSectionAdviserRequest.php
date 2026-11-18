<?php

namespace App\Http\Requests\Section;

use App\Http\Requests\BaseApiRequest;

class AssignSectionAdviserRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'adviser_id' => ['nullable'],
        ];
    }
}
