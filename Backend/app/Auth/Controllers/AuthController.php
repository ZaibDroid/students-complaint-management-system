<?php

namespace App\Auth\Controllers;

use App\Auth\Requests\LoginRequest;
use App\Auth\Requests\RefreshRequest;
use App\Auth\Requests\ForgotPasswordRequest;
use App\Auth\Requests\ResetPasswordOTPRequest;
use App\Auth\Resources\AuthResource;
use App\Auth\Services\AuthService;
use App\Auth\Services\DeviceService;
use App\Auth\Services\TokenService;
use App\Http\Controllers\Api\V1\BaseApiController;
use App\Models\UserDevice;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AuthController extends BaseApiController
{
    public function __construct(
        protected AuthService $authService,
        protected TokenService $tokenService,
        protected DeviceService $deviceService
    ) {}

    public function login(LoginRequest $request): JsonResponse
    {
        $user = $this->authService->validateCredentials(
            $request->input('identifier'),
            $request->input('password')
        );

        if (!$user) {
            $this->authService->recordLoginAttempt(
                $user, 
                $request->ip(), 
                $request->input('device_name'), 
                $request->input('platform'), 
                false, 
                'Invalid credentials'
            );
            return $this->errorResponse('Invalid credentials.', 401);
        }

        $this->authService->recordLoginAttempt(
            $user, 
            $request->ip(), 
            $request->input('device_name'), 
            $request->input('platform'), 
            true
        );

        // Generate Tokens
        $accessToken = $this->tokenService->issueAccessToken($user, $request->input('device_name') ?? 'Unknown Device');
        $rawRefreshToken = $this->tokenService->generateRefreshToken();
        $refreshTokenHash = $this->tokenService->hashRefreshToken($rawRefreshToken);
        $refreshTokenExpiresAt = $this->tokenService->getRefreshTokenExpiration();

        // Register Device
        $this->deviceService->registerOrUpdateDevice($user, $request, $refreshTokenHash, $refreshTokenExpiresAt);

        // Fire Event
        event(new \App\Auth\Events\UserLoggedIn($user));

        return $this->successResponse(
            new AuthResource([
                'user' => $user->load(['department', 'batch', 'section']),
                'access_token' => $accessToken,
                'refresh_token' => $rawRefreshToken,
            ]),
            'Login successful.'
        );
    }

    public function refresh(RefreshRequest $request): JsonResponse
    {
        $rawRefreshToken = $request->input('refresh_token');
        $hash = $this->tokenService->hashRefreshToken($rawRefreshToken);

        $device = UserDevice::where('refresh_token_hash', $hash)->first();

        if (!$device || !$device->refresh_token_expires_at || $device->refresh_token_expires_at->isPast() || $device->revoked_at) {
            return $this->errorResponse('Invalid or expired refresh token.', 401);
        }

        $user = $device->user;

        // Revoke current Sanctum token (if possible, though typically they just expire. If we pass the access token, we could revoke it).
        // Best effort: we just issue a new pair and rotate the refresh token.

        $accessToken = $this->tokenService->issueAccessToken($user, $device->device_name ?? 'Unknown Device');
        $newRawRefreshToken = $this->tokenService->generateRefreshToken();
        $newRefreshTokenHash = $this->tokenService->hashRefreshToken($newRawRefreshToken);

        // Update device
        $device->update([
            'refresh_token_hash' => $newRefreshTokenHash,
            'refresh_token_expires_at' => $this->tokenService->getRefreshTokenExpiration(),
            'last_used_at' => now(),
            'ip_address' => $request->ip(),
        ]);

        event(new \App\Auth\Events\RefreshTokenUsed($user, $device));

        return $this->successResponse(
            new AuthResource([
                'user' => $user->load(['department', 'batch', 'section']),
                'access_token' => $accessToken,
                'refresh_token' => $newRawRefreshToken,
            ]),
            'Token refreshed successfully.'
        );
    }

    public function logoutCurrent(): JsonResponse
    {
        $user = request()->user();
        
        // Revoke current Sanctum token
        $user->currentAccessToken()->delete();

        // Try to find the device and revoke it if a refresh token was somehow linked (we typically don't have it on logout request unless passed).
        // Alternatively, the EnsureDeviceIsActive middleware updates last_used_at. 
        // We will just dispatch event for now.
        event(new \App\Auth\Events\UserLoggedOut($user));

        return $this->successResponse([], 'Logged out successfully.');
    }

    public function logoutAll(): JsonResponse
    {
        $user = request()->user();
        
        // Revoke all Sanctum tokens
        $user->tokens()->delete();

        // Revoke all devices
        $user->devices()->update([
            'refresh_token_hash' => null,
            'refresh_token_expires_at' => null,
            'revoked_at' => now(),
        ]);

        return $this->successResponse([], 'Logged out of all devices successfully.');
    }

    public function forgotPassword(ForgotPasswordRequest $request): JsonResponse
    {
        $email = $request->input('email');
        
        $otp = $this->authService->generatePasswordResetOTP($email);

        // Here we would normally send an email:
        // Mail::to($email)->send(new \App\Mail\PasswordResetOTP($otp));
        // For development, we can just return it or mock it.
        // In production, NEVER return the OTP in the API response.

        return $this->successResponse(
            ['debug_otp' => $otp], // REMOVE IN PRODUCTION
            'A 6-digit OTP has been sent to your email.'
        );
    }

    public function resetPassword(ResetPasswordOTPRequest $request): JsonResponse
    {
        $email = $request->input('email');
        $otp = $request->input('otp');
        $password = $request->input('password');

        if (!$this->authService->validatePasswordResetOTP($email, $otp)) {
            return $this->errorResponse('Invalid or expired OTP.', 400);
        }

        $user = User::where('email', $email)->first();
        $user->update([
            'password' => Hash::make($password),
            'must_change_password' => false,
        ]);

        // Revoke all existing tokens/devices since password changed
        $user->tokens()->delete();
        $user->devices()->update([
            'refresh_token_hash' => null,
            'refresh_token_expires_at' => null,
            'revoked_at' => now(),
        ]);

        event(new \App\Auth\Events\PasswordReset($user));

        return $this->successResponse([], 'Password has been reset successfully. Please log in again.');
    }
}
