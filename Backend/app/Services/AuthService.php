<?php

namespace App\Services;

use App\Contracts\Repositories\UserRepositoryInterface;
use App\Contracts\Services\AuthServiceInterface;
use App\Exceptions\ApiException;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class AuthService implements AuthServiceInterface
{
    protected UserRepositoryInterface $userRepository;

    public function __construct(UserRepositoryInterface $userRepository)
    {
        $this->userRepository = $userRepository;
    }

    protected function resolveBatchSectionAndAdviser(array &$data, ?User $user = null): void
    {
        $batchName = $data['batch'] ?? null;
        $sectionName = $data['section'] ?? null;
        $deptName = $data['department'] ?? null;

        unset($data['batch'], $data['section'], $data['department']);

        if ($deptName !== null && $deptName !== '') {
            $deptStr = trim((string)$deptName);
            $dept = \App\Models\Department::where('name', $deptStr)
                ->orWhere('code', $deptStr)
                ->first();
            if ($dept) {
                $data['department_id'] = $dept->id;
            }
        }

        $batchId = $data['batch_id'] ?? ($user ? $user->batch_id : null);

        if ($batchName !== null && $batchName !== '') {
            $rawStr = trim((string)$batchName);
            $batchYear = 0;
            if (is_numeric($rawStr)) {
                $num = (int)$rawStr;
                if ($num >= 2000) {
                    $batchYear = $num;
                } else if ($num >= 1 && $num <= 50) {
                    $batchYear = 2017 + $num;
                }
            } else if (preg_match('/\b(20\d{2})\b/', $rawStr, $m)) {
                $batchYear = (int)$m[1];
            } else if (preg_match('/Batch\s*(\d+)/i', $rawStr, $m)) {
                $num = (int)$m[1];
                $batchYear = $num >= 2000 ? $num : (2017 + $num);
            }

            if ($batchYear < 2018) {
                $batchYear = (int)date('Y');
            }

            $canonicalName = (string)$batchYear;

            $batch = \App\Models\Batch::where('name', $canonicalName)
                ->orWhere('name', $rawStr)
                ->orWhere('start_year', $batchYear)
                ->first();

            if (!$batch) {
                $batch = \App\Models\Batch::create([
                    'name' => $canonicalName,
                    'start_year' => $batchYear,
                    'end_year' => $batchYear + 4,
                ]);
            }

            $batchId = $batch->id;
            $data['batch_id'] = $batchId;
        }

        if ($sectionName !== null && $sectionName !== '') {
            $secName = strtoupper(trim((string)$sectionName));
            if ($batchId) {
                $section = \App\Models\Section::firstOrCreate([
                    'batch_id' => $batchId,
                    'name' => $secName,
                ]);
                $data['section_id'] = $section->id;
            }
        }
    }

    public function registerStudent(array $data): array
    {
        $data['password'] = Hash::make($data['password']);
        $data['status'] = 'unlinked'; // Student starts as unlinked, must send request to Batch Adviser
        $data['adviser_id'] = null;   // No auto-linking of adviser

        $this->resolveBatchSectionAndAdviser($data);

        /** @var User $user */
        $user = $this->userRepository->create($data);
        $user->assignRole('Student');

        $token = $user->createToken('auth_token')->plainTextToken;

        return [
            'user' => $user->load(['department', 'batch', 'section', 'roles']),
            'token' => $token,
            'token_type' => 'Bearer',
        ];
    }

    public function login(string $email, string $password): array
    {
        $user = $this->userRepository->findByEmail($email);

        if (!$user || !Hash::check($password, $user->password)) {
            throw new ApiException('Invalid login credentials', 401);
        }

        if ($user->status !== 'approved' && $user->status !== 'unlinked' && $user->status !== 'pending') {
            throw new ApiException('Your account is not approved yet', 403);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        event(new \App\Auth\Events\UserLoggedIn($user));

        return [
            'user' => $user->load(['department', 'batch', 'section', 'adviser', 'roles', 'assignedSections']),
            'token' => $token,
            'token_type' => 'Bearer',
        ];
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()->delete();
    }

    public function changePassword(User $user, string $oldPassword, string $newPassword): void
    {
        if (!Hash::check($oldPassword, $user->password)) {
            throw new ApiException('Current password provided is incorrect', 400);
        }

        $user->password = Hash::make($newPassword);
        $user->save();

        event(new \App\Auth\Events\PasswordReset($user));
    }

    public function updateProfile(User $user, array $data): User
    {
        $this->resolveBatchSectionAndAdviser($data, $user);
        $this->userRepository->update($user->id, $data);
        return $user->fresh(['department', 'batch', 'section', 'roles', 'adviser']);
    }

    public function uploadProfileImage(User $user, UploadedFile $file): string
    {
        if ($user->profile_image_url) {
            $oldPath = str_replace(asset('storage/'), '', $user->profile_image_url);
            Storage::disk('public')->delete($oldPath);
        }

        $path = $file->store('profiles', 'public');
        $url = asset('storage/' . $path);

        $this->userRepository->update($user->id, [
            'profile_image_url' => $url,
        ]);

        return $url;
    }
}
