<?php

namespace App\Http\Requests\User;

use App\Http\Requests\BaseApiRequest;
use Illuminate\Validation\Rule;

class UpdateStaffRequest extends BaseApiRequest
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
        if (!$this->has('department_id') && $this->has('department') && !empty($this->input('department'))) {
            $deptStr = trim((string)$this->input('department'));
            $cleanName = trim(preg_replace('/^(department\s*of\s*|dept\s*of\s*)/i', '', $deptStr));
            $dept = \App\Models\Department::where('name', $deptStr)
                ->orWhere('name', 'LIKE', "%{$cleanName}%")
                ->first();
            if ($dept) {
                $this->merge(['department_id' => $dept->id]);
            }
        }
    }

    public function rules(): array
    {
        $userId = $this->route('user') ? $this->route('user')->id : null;

        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'string', 'email', 'max:255', Rule::unique('users', 'email')->ignore($userId)->whereNull('deleted_at')],
            'password' => ['nullable', 'string', 'min:6'],
            'role' => ['sometimes', 'string', 'exists:roles,name'],
            'department_id' => ['nullable', 'exists:departments,id'],
            'department' => ['nullable', 'string', 'max:100'],
            'phone' => ['nullable', 'string', 'max:20'],
            'batch' => ['nullable', 'string'],
            'batch_id' => ['nullable'],
            'section' => ['nullable', 'string'],
            'section_id' => ['nullable'],
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

            if ($this->has('role')) {
                $requestedRole = (string)$this->input('role');
                if ($user->hasRole('Coordinator')) {
                    $allowed = ['Batch Adviser', 'Batch Advisor', 'Office Staff'];
                    if (!in_array($requestedRole, $allowed, true)) {
                        $validator->errors()->add('role', 'Coordinators can only assign Batch Adviser or Office Staff roles.');
                    }
                } elseif ($user->hasRole('Chairman')) {
                    $allowed = ['Coordinator', 'Batch Adviser', 'Batch Advisor', 'Office Staff'];
                    if (!in_array($requestedRole, $allowed, true)) {
                        $validator->errors()->add('role', 'Chairmen cannot assign Admin or Chairman roles.');
                    }
                }
            }

            if ($this->has('department_id')) {
                $requestedDept = (int)$this->input('department_id');
                if (($user->hasRole('Coordinator') || $user->hasRole('Chairman')) && $requestedDept !== (int)$user->department_id) {
                    $validator->errors()->add('department_id', 'You cannot reassign staff members outside your department.');
                }
            }
        });
    }
}
