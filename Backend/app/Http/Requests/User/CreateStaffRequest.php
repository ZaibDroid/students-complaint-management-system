<?php

namespace App\Http\Requests\User;

use App\Http\Requests\BaseApiRequest;
use Illuminate\Validation\Rule;

class CreateStaffRequest extends BaseApiRequest
{
    public function authorize(): bool
    {
        $user = $this->user();
        if (!$user) {
            return false;
        }

        return $user->hasAnyRole(['Admin', 'Super Admin', 'Chairman', 'Coordinator']);
    }

    protected function prepareForValidation(): void
    {
        $user = $this->user();
        if ($user && ($user->hasRole('Coordinator') || $user->hasRole('Chairman'))) {
            if (!$this->has('department_id') && $user->department_id) {
                $this->merge(['department_id' => $user->department_id]);
            }
        }
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', Rule::unique('users', 'email')->whereNull('deleted_at')],
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

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $user = $this->user();
            if (!$user) {
                return;
            }

            $requestedRole = (string)$this->input('role');

            if ($user->hasRole('Coordinator')) {
                $allowed = ['Batch Adviser', 'Batch Advisor', 'Office Staff'];
                if (!in_array($requestedRole, $allowed, true)) {
                    $validator->errors()->add('role', 'Coordinators can only create Batch Adviser or Office Staff accounts.');
                }
                if ($this->has('department_id') && (int)$this->input('department_id') !== (int)$user->department_id) {
                    $validator->errors()->add('department_id', 'Coordinators can only create staff within their own department.');
                }
            } elseif ($user->hasRole('Chairman')) {
                $allowed = ['Coordinator', 'Batch Adviser', 'Batch Advisor', 'Office Staff'];
                if (!in_array($requestedRole, $allowed, true)) {
                    $validator->errors()->add('role', 'Chairmen can only create Coordinator, Batch Adviser, or Office Staff accounts.');
                }
                if ($this->has('department_id') && (int)$this->input('department_id') !== (int)$user->department_id) {
                    $validator->errors()->add('department_id', 'Chairmen can only create staff within their own department.');
                }
            } elseif (!$user->hasRole('Admin')) {
                $validator->errors()->add('role', 'You are not authorized to create staff accounts.');
            }
        });
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'An account with this email address already exists in the system.',
            'password.min' => 'The temporary password must be at least 6 characters.',
        ];
    }
}
