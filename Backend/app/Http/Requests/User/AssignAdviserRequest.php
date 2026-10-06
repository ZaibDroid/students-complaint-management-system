<?php

namespace App\Http\Requests\User;

use App\Http\Requests\BaseApiRequest;

class AssignAdviserRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'adviser_id' => ['required', 'string'],
        ];
    }
}
