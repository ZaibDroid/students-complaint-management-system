<?php

namespace App\Http\Requests\User;

use App\Http\Requests\BaseApiRequest;

class UpdateStaffRequest extends BaseApiRequest
{
    public function rules(): array
    {
        $userId = $this->route('user') ? $this->route('user')->id : null;

        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'string', 'email', 'max:255', 'unique:users,email,' . $userId],
            'password' => ['nullable', 'string', 'min:6'],
            'role' => ['sometimes', 'string', 'exists:roles,name'],
            'department_id' => ['nullable', 'exists:departments,id'],
            'phone' => ['nullable', 'string', 'max:20'],
            'batch' => ['nullable', 'string'],
            'section' => ['nullable', 'string'],
            'semester' => ['nullable', 'string'],
            'assigned_sections' => ['nullable', 'array'],
        ];
    }
}
