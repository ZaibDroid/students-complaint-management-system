<?php

namespace App\Contracts\Services;

use App\Models\User;
use Illuminate\Http\UploadedFile;

interface AuthServiceInterface
{
    public function registerStudent(array $data): array;

    public function login(string $email, string $password): array;

    public function logout(User $user): void;

    public function changePassword(User $user, string $oldPassword, string $newPassword): void;

    public function updateProfile(User $user, array $data): User;

    public function uploadProfileImage(User $user, UploadedFile $file): string;
}
