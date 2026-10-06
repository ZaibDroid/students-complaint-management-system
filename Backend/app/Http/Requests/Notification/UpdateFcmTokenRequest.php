<?php

namespace App\Http\Requests\Notification;

use App\Http\Requests\BaseApiRequest;

class UpdateFcmTokenRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'token' => ['sometimes', 'string'],
            'device_type' => ['sometimes', 'string', 'in:android,ios,web'],
        ];
    }
}
