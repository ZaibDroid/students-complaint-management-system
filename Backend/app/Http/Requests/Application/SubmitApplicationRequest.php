<?php

namespace App\Http\Requests\Application;

use App\Http\Requests\BaseApiRequest;

class SubmitApplicationRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'category_id' => ['nullable'],
            'category' => ['nullable'],
            'priority' => ['nullable', 'in:low,medium,high,urgent'],
            'attachment' => ['nullable', 'file', 'mimes:jpeg,png,jpg,webp,pdf,doc,docx', 'max:5120'],
            'attachments' => ['nullable'],
        ];
    }
}
