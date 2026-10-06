<?php

namespace App\Auth\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class ResetPasswordOTPRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email', 'exists:users,email'],
            'otp' => ['required', 'string', 'size:6'],
            'password' => ['required', 'confirmed', Password::defaults()],
        ];
    }
}
