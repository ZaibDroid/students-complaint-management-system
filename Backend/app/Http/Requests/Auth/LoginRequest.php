<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\BaseApiRequest;

class LoginRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
        ];
    }
}
