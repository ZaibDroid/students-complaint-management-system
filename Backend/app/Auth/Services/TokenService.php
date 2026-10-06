<?php

namespace App\Auth\Services;

use App\Models\User;
use Illuminate\Support\Str;

class TokenService
{
    /**
     * Issue a short-lived access token.
     */
    public function issueAccessToken(User $user, string $deviceName): \Laravel\Sanctum\NewAccessToken
    {
        $abilities = ['*']; // Abilities can be restricted later if needed
        $expiresAt = now()->addMinutes(config('auth.access_token_lifetime', 120)); // Default 2 hours

        return $user->createToken($deviceName, $abilities, $expiresAt);
    }

    /**
     * Generate a new cryptographically secure refresh token.
     */
    public function generateRefreshToken(): string
    {
        return Str::uuid()->toString() . '-' . Str::random(40);
    }

    /**
     * Hash the refresh token for storage.
     */
    public function hashRefreshToken(string $token): string
    {
        return hash('sha256', $token);
    }

    /**
     * Get the expiration date for a refresh token.
     */
    public function getRefreshTokenExpiration(): \Illuminate\Support\Carbon
    {
        return now()->addDays(config('auth.refresh_token_lifetime', 30)); // Default 30 days
    }
}
