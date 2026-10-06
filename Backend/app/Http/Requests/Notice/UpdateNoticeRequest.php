<?php

namespace App\Http\Requests\Notice;

use App\Http\Requests\BaseApiRequest;

class UpdateNoticeRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'title' => ['sometimes', 'string', 'max:255'],
            'description' => ['sometimes', 'string'],
            'tag' => ['sometimes', 'string', 'max:50'],
            'attachment' => ['nullable', 'file', 'mimes:jpeg,png,jpg,webp,pdf,doc,docx', 'max:10240'],
            'targets' => ['nullable', 'array'],
            'targets.*.type' => ['required', 'string', 'in:all_students,all_staff,year,batch_id,section_id,role,crs_only'],
            'targets.*.value' => ['nullable', 'string'],
        ];
    }
}
