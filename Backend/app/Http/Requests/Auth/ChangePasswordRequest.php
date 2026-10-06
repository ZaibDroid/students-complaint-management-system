<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\BaseApiRequest;

class ChangePasswordRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'old_password' => ['required', 'string'],
            'new_password' => ['required', 'string', 'min:8', 'confirmed'],
        ];
    }
}
