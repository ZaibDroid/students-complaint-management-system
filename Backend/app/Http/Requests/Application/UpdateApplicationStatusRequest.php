<?php

namespace App\Http\Requests\Application;

use App\Http\Requests\BaseApiRequest;

class UpdateApplicationStatusRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'status' => ['required', 'string', 'in:draft,submitted,under_review,forwarded,assigned,in_progress,resolved,rejected,returned,closed'],
            'assigned_to_id' => ['nullable', 'exists:users,id'],
            'notes' => ['nullable', 'string'],
        ];
    }
}
