<?php

namespace App\Http\Requests\Batch;

use App\Http\Requests\BaseApiRequest;

class UpdateBatchRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'start_year' => ['sometimes', 'integer', 'digits:4'],
            'end_year' => ['sometimes', 'integer', 'digits:4'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
