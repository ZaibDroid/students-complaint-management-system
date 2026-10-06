<?php

namespace App\Http\Requests\User;

use App\Http\Requests\BaseApiRequest;

class CreateStaffRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6'],
            'role' => ['required', 'string', 'exists:roles,name'],
            'department_id' => ['nullable', 'exists:departments,id'],
            'phone' => ['nullable', 'string', 'max:20'],
            'batch' => ['nullable', 'string'],
            'section' => ['nullable', 'string'],
            'semester' => ['nullable', 'string'],
            'assigned_sections' => ['nullable', 'array'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'An account with this email address already exists in the system.',
            'password.min' => 'The temporary password must be at least 6 characters.',
        ];
    }
}
