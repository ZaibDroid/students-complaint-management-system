<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\BaseApiRequest;

class RegisterStudentRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => [
                'required',
                'string',
                'email',
                'max:255',
                'unique:users,email',
                'regex:/^[a-zA-Z0-9._%+-]+@uetmardan\.edu\.pk$/i',
            ],
            'password' => ['required', 'string', 'min:6'],
            'department_id' => ['nullable', 'exists:departments,id'],
            'department' => ['nullable', 'string', 'max:100'],
            'batch_id' => ['nullable', 'exists:batches,id'],
            'batch' => ['nullable', 'string', 'max:50'],
            'section_id' => ['nullable', 'exists:sections,id'],
            'section' => ['nullable', 'string', 'max:20'],
            'year' => ['nullable', 'string'],
            'semester' => ['nullable', 'string'],
            'current_semester' => ['nullable', 'integer', 'min:1', 'max:8'],
            'registration_number' => ['nullable', 'string', 'max:50'],
            'adviser_id' => ['nullable', 'exists:users,id'],
            'adviser' => ['nullable', 'string', 'max:100'],
            'phone' => ['nullable', 'string', 'max:20'],
            'status' => ['nullable', 'string'],
            'is_cr' => ['prohibited'],
            'isCR' => ['prohibited'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.regex' => 'Registration is restricted to official @uetmardan.edu.pk email addresses.',
            'is_cr.prohibited' => 'Students cannot assign themselves Class Representative status during registration.',
            'isCR.prohibited' => 'Students cannot assign themselves Class Representative status during registration.',
        ];
    }
}
