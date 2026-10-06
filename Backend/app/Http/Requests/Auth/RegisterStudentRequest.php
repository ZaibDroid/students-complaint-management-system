<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\BaseApiRequest;

class RegisterStudentRequest extends BaseApiRequest
{
    protected function prepareForValidation(): void
    {
        if ($this->has('isCR') && !$this->has('is_cr')) {
            $this->merge(['is_cr' => $this->boolean('isCR')]);
        }
    }

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
            'batch_id' => ['nullable', 'exists:batches,id'],
            'section_id' => ['nullable', 'exists:sections,id'],
            'year' => ['nullable', 'string'],
            'semester' => ['nullable', 'string'],
            'adviser_id' => ['nullable', 'exists:users,id'],
            'phone' => ['nullable', 'string', 'max:20'],
            'is_cr' => ['nullable', 'boolean'],
            'isCR' => ['nullable', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.regex' => 'Registration is restricted to official @uetmardan.edu.pk email addresses.',
        ];
    }
}
