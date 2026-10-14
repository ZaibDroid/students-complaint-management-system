<?php

namespace App\Http\Requests\Notice;

use App\Http\Requests\BaseApiRequest;

class CreateNoticeRequest extends BaseApiRequest
{
    protected function prepareForValidation(): void
    {
        if (is_string($this->targets)) {
            $decoded = json_decode($this->targets, true);
            if (is_array($decoded)) {
                $this->merge(['targets' => $decoded]);
            }
        }
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'tag' => ['nullable', 'string', 'max:50'], // Academic, Events, Urgent, General
            'status' => ['nullable', 'string', 'in:draft,published,scheduled,expired'],
            'scheduled_at' => ['nullable', 'date'],
            'attachment' => ['nullable', 'file', 'mimes:jpeg,png,jpg,webp,pdf,doc,docx', 'max:10240'],
            'attachments' => ['nullable'],
            'attachments.*' => ['file', 'mimes:jpeg,png,jpg,webp,pdf,doc,docx', 'max:10240'],
            'targets' => ['nullable', 'array'],
            'targets.*.type' => ['required', 'string', 'in:all_students,all_staff,year,batch,batch_id,section,section_id,role,crs_only,department_id'],
            'targets.*.value' => ['nullable', 'string'],
        ];
    }
}
