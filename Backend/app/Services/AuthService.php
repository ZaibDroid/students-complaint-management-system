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
            $shortSec = trim(preg_replace('/^(section\s*|sec\s*)/i', '', $secName));
            $longSec = 'Section ' . $shortSec;
            if ($batchId) {
                $section = \App\Models\Section::where('batch_id', $batchId)
                    ->where(function ($q) use ($secName, $shortSec, $longSec) {
                        $q->where('name', $secName)
                          ->orWhere('name', $shortSec)
                          ->orWhere('name', $longSec);
                    })
                    ->first();

                if (!$section) {
                    $section = \App\Models\Section::create([
                        'batch_id' => $batchId,
                        'name' => $longSec,
                    ]);
                }
                $data['section_id'] = $section->id;
            }
        }

        $yearInput = $data['year'] ?? $data['semester'] ?? $data['current_semester'] ?? null;
        if ($yearInput !== null && $yearInput !== '') {
            $semNum = null;
            if (is_numeric($yearInput)) {
                $semNum = (int)$yearInput;
            } elseif (preg_match('/(?:semester|sem)\s*(\d+)/i', (string)$yearInput, $m)) {
                $semNum = (int)$m[1];
            }
            if ($semNum !== null && $semNum >= 1 && $semNum <= 8) {
                $data['current_semester'] = $semNum;
                $data['semester'] = "Semester {$semNum}";
            }
        }
        unset($data['year']);
    }

    public function registerStudent(array $data): array
    {
        // Enforce privilege isolation: prevent student self-promotion to CR or custom roles
        unset($data['is_cr'], $data['isCR'], $data['role']);
        $data['is_cr'] = false;
        $data['password'] = Hash::make($data['password']);
        $data['status'] = 'unlinked'; // Student starts as unlinked, must send request to Batch Adviser
        $data['adviser_id'] = null;   // No auto-linking of adviser

        if (!empty($data['email']) && str_contains($data['email'], '@')) {
            $parts = explode('@', $data['email'], 2);
            $local = trim($parts[0]);
            $domain = strtolower(trim($parts[1]));
            if (preg_match('/^\d{2}[A-Za-z]+\d+$/', $local)) {
                $local = strtoupper($local);
            }
            $data['email'] = $local . '@' . $domain;
        }

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
        if ($user->hasRole('Batch Adviser')) {
            unset($data['batch'], $data['batch_id'], $data['section'], $data['section_id']);
        }
        $this->resolveBatchSectionAndAdviser($data, $user);
        $this->userRepository->update($user->id, $data);
        return $user->fresh(['department', 'batch', 'section', 'roles', 'adviser', 'assignedSections']);
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
