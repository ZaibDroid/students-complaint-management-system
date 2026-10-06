<?php

namespace App\Http\Requests\User;

use App\Http\Requests\BaseApiRequest;

class UpdateCrStatusRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'is_cr' => ['required', 'boolean'],
        ];
    }
}
