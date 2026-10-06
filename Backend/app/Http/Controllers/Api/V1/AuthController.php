<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\AuthServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Requests\Auth\ChangePasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterStudentRequest;
use App\Http\Requests\Auth\UpdateProfileRequest;
use App\Http\Requests\Auth\UploadProfileImageRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends BaseApiController
{
    protected AuthServiceInterface $authService;

    public function __construct(AuthServiceInterface $authService)
    {
        $this->authService = $authService;
    }

    public function registerStudent(RegisterStudentRequest $request): JsonResponse
    {
        $result = $this->authService->registerStudent($request->validated());

        return $this->createdResponse([
            'user' => new UserResource($result['user']),
            'token' => $result['token'],
            'token_type' => $result['token_type'],
        ], 'Student registered successfully');
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->login($request->email, $request->password);

        return $this->successResponse([
            'user' => new UserResource($result['user']),
            'token' => $result['token'],
            'token_type' => $result['token_type'],
        ], 'Login successful');
    }

    public function logout(Request $request): JsonResponse
    {
        $this->authService->logout($request->user());

        return $this->successResponse(null, 'Successfully logged out');
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load(['department', 'batch', 'section', 'adviser', 'roles', 'assignedSections']);

        return $this->successResponse(new UserResource($user), 'User profile fetched successfully');
    }

    public function updateProfile(UpdateProfileRequest $request): JsonResponse
    {
        $updatedUser = $this->authService->updateProfile($request->user(), $request->validated());

        return $this->successResponse(new UserResource($updatedUser), 'Profile updated successfully');
    }

    public function changePassword(ChangePasswordRequest $request): JsonResponse
    {
        $this->authService->changePassword($request->user(), $request->old_password, $request->new_password);

        return $this->successResponse(null, 'Password updated successfully');
    }

    public function uploadProfileImage(UploadProfileImageRequest $request): JsonResponse
    {
        $url = $this->authService->uploadProfileImage($request->user(), $request->file('image'));

        return $this->successResponse([
            'profile_image_url' => $url,
        ], 'Profile image uploaded successfully');
    }
}
