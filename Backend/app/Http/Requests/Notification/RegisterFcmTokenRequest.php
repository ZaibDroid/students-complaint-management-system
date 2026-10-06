<?php

namespace App\Http\Requests\Notification;

use App\Http\Requests\BaseApiRequest;

class RegisterFcmTokenRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'token' => ['required', 'string'],
            'device_type' => ['nullable', 'string', 'in:android,ios,web'],
        ];
    }
}
