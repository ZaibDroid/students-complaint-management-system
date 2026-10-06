<?php

namespace App\Http\Requests\Setting;

use App\Http\Requests\BaseApiRequest;

class UpdateSettingRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'settings' => ['required', 'array'],
        ];
    }
}
