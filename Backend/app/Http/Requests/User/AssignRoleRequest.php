<?php

namespace App\Http\Requests\User;

use App\Http\Requests\BaseApiRequest;

class AssignRoleRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'roles' => ['required', 'array', 'min:1'],
            'roles.*' => ['string', 'exists:roles,name'],
        ];
    }
}
