<?php

namespace App\Auth\Requests;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'identifier' => ['required', 'string'], // Email or Registration Number
            'password' => ['required', 'string'],
            'device_id' => ['required', 'string'], // Flutter hardware ID
            'device_name' => ['nullable', 'string'],
            'platform' => ['nullable', 'string'],
            'app_version' => ['nullable', 'string'],
            'os_version' => ['nullable', 'string'],
            'push_token' => ['nullable', 'string'],
        ];
    }
}
