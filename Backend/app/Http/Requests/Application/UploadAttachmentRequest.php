<?php

namespace App\Http\Requests\Application;

use App\Http\Requests\BaseApiRequest;

class UploadAttachmentRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'attachments' => ['required', 'array', 'min:1', 'max:5'],
            'attachments.*' => ['file', 'mimes:jpeg,png,jpg,webp,pdf,doc,docx', 'max:10240'],
        ];
    }
}
