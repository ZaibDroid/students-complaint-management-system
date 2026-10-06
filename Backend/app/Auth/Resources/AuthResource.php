<?php

namespace App\Auth\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AuthResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        $user = $this->resource['user'];
        $token = $this->resource['access_token'];
        $refreshToken = $this->resource['refresh_token'] ?? null;

        return [
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'registration_number' => $user->registration_number,
                'must_change_password' => (bool) $user->must_change_password,
                // Nested relationships that Flutter needs immediately
                'department' => $user->relationLoaded('department') ? $user->department : null,
                'batch' => $user->relationLoaded('batch') ? $user->batch : null,
                'section' => $user->relationLoaded('section') ? $user->section : null,
            ],
            'roles' => $user->getRoleNames(),
            'permissions' => $user->getAllPermissions()->pluck('name'),
            'access_token' => $token->plainTextToken,
            'refresh_token' => $refreshToken,
            'expires_at' => $token->accessToken->expires_at ? $token->accessToken->expires_at->toIso8601String() : null,
            'server_time' => now()->toIso8601String(),
            'api_version' => 'v1',
        ];
    }
}
