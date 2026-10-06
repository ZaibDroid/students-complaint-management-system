<?php

namespace App\Http\Requests\Department;

use App\Http\Requests\BaseApiRequest;

class UpdateDepartmentRequest extends BaseApiRequest
{
    public function rules(): array
    {
        $departmentId = $this->route('department') ? $this->route('department')->id : null;

        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'code' => ['sometimes', 'string', 'max:50', 'unique:departments,code,' . $departmentId],
            'description' => ['nullable', 'string'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
