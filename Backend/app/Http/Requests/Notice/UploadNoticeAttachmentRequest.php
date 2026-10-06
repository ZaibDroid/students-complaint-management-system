<?php

namespace App\Http\Requests\Notice;

use App\Http\Requests\BaseApiRequest;

class UploadNoticeAttachmentRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'attachment' => ['required', 'file', 'mimes:jpeg,png,jpg,webp,pdf,doc,docx', 'max:10240'],
        ];
    }
}
