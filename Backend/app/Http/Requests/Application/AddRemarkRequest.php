<?php

namespace App\Http\Requests\Application;

use App\Http\Requests\BaseApiRequest;

class AddRemarkRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'remark' => ['required', 'string'],
            'action_taken' => ['nullable', 'string', 'max:100'],
        ];
    }
}
