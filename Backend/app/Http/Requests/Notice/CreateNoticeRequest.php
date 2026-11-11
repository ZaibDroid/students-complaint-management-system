<?php

namespace App\Http\Requests\Notice;

use App\Http\Requests\BaseApiRequest;

class CreateNoticeRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'tag' => ['nullable', 'string', 'max:50'], // Academic, Events, Urgent, General
            'attachment' => ['nullable', 'file', 'mimes:jpeg,png,jpg,webp,pdf,doc,docx', 'max:10240'],
            'department_id' => ['nullable', 'exists:departments,id'],
            'target_batch_id' => ['nullable', 'exists:batches,id'],
            'target_section_id' => ['nullable', 'exists:sections,id'],
            'target_role' => ['nullable', 'string', 'max:50'],
            'targets' => ['nullable', 'array'],
            'targets.*.type' => ['required', 'string', 'in:all_students,all_staff,year,batch_id,section_id,role,crs_only'],
            'targets.*.value' => ['nullable', 'string'],
        ];
    }
}
