<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\BaseApiRequest;

class UploadProfileImageRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'image' => ['required', 'image', 'mimes:jpeg,png,jpg,webp', 'max:5120'],
        ];
    }
}
