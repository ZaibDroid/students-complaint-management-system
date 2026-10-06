<?php

namespace App\Http\Requests\Application;

use App\Http\Requests\BaseApiRequest;

class UpdateApplicationRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'title' => ['sometimes', 'string', 'max:255'],
            'description' => ['sometimes', 'string'],
            'category' => ['sometimes', 'string', 'max:100'],
            'priority' => ['sometimes', 'in:low,medium,high,urgent'],
        ];
    }
}
