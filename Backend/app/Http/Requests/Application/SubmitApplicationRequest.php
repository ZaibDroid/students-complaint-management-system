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
            'category_id' => ['required', 'exists:application_categories,id'],
            'priority' => ['nullable', 'in:low,medium,high,urgent'],
            'attachment' => ['nullable', 'file', 'mimes:jpeg,png,jpg,webp,pdf,doc,docx', 'max:5120'],
        ];
    }
}
