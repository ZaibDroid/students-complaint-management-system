<?php

namespace App\Services;

use App\Contracts\Repositories\UserRepositoryInterface;
use App\Contracts\Services\UserServiceInterface;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Hash;

class UserService implements UserServiceInterface
{
    protected UserRepositoryInterface $userRepository;

    public function __construct(UserRepositoryInterface $userRepository)
    {
        $this->userRepository = $userRepository;
    }

    protected function resolveBatchAndSection(array &$data): ?int
    {
        $batchName = $data['batch'] ?? null;
        $sectionName = $data['section'] ?? null;

        unset($data['batch'], $data['section']);

        if ($batchName !== null && $batchName !== '') {
            $rawStr = trim((string)$batchName);
            $batchYear = 0;
            if (is_numeric($rawStr)) {
                $num = (int)$rawStr;
                if ($num >= 2000) {
                    $batchYear = $num;
                } else if ($num >= 1 && $num <= 50) {
                    $batchYear = 2017 + $num; // e.g. Batch 6 -> 2023
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

            $canonicalName = (string)$batchYear; // e.g. "2023"

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

            $data['batch_id'] = $batch->id;

            if ($sectionName !== null && $sectionName !== '') {
                $secName = strtoupper(trim((string)$sectionName));
                $section = \App\Models\Section::firstOrCreate([
                    'batch_id' => $batch->id,
                    'name' => $secName,
                ]);
                $data['section_id'] = $section->id;
                return $section->id;
            }
        }
        return null;
    }

    public function createStaff(array $data): User
    {
        $data['password'] = Hash::make($data['password']);
        $data['status'] = 'approved';

        $role = $data['role'] ?? 'Office Staff';
        unset($data['role']);

        $assignedSections = $data['assigned_sections'] ?? [];
        unset($data['assigned_sections']);

        $createdSectionId = $this->resolveBatchAndSection($data);

        /** @var User $user */
        $user = $this->userRepository->create($data);
        $user->assignRole($role);

        if (!empty($assignedSections)) {
            $this->userRepository->assignSectionsToUser($user, $assignedSections);
        }

        if ($createdSectionId) {
            $user->assignedSections()->syncWithoutDetaching([$createdSectionId]);
        }

        return $user->load(['department', 'batch', 'section', 'roles', 'assignedSections']);
    }

    public function updateStaff(User $user, array $data): User
    {
        if (isset($data['password']) && !empty($data['password'])) {
            $data['password'] = Hash::make($data['password']);
        } else {
            unset($data['password']);
        }

        if (isset($data['role'])) {
            $user->syncRoles([$data['role']]);
            unset($data['role']);
        }

        if (isset($data['assigned_sections'])) {
            $this->userRepository->assignSectionsToUser($user, $data['assigned_sections']);
            unset($data['assigned_sections']);
        }

        $createdSectionId = $this->resolveBatchAndSection($data);

        $this->userRepository->update($user->id, $data);

        if ($createdSectionId) {
            $user->assignedSections()->syncWithoutDetaching([$createdSectionId]);
        }

        return $user->fresh(['department', 'batch', 'section', 'roles', 'assignedSections']);
    }

    public function deleteStaff(User $user): void
    {
        $this->userRepository->delete($user->id);
    }

    public function listUsers(array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        return $this->userRepository->getUsers($filters, $perPage);
    }

    public function listStaff(array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        return $this->userRepository->getStaffMembers($filters, $perPage);
    }

    public function getUserDetails(User $user): User
    {
        return $user->load(['department', 'batch', 'section', 'adviser', 'roles', 'assignedSections']);
    }

    public function assignRoles(User $user, array $roles): User
    {
        $user->syncRoles($roles);
        return $user->fresh(['roles']);
    }

    public function assignAdviser(User $user, int|string $adviserIdOrName): User
    {
        $adviser = User::where('id', $adviserIdOrName)
            ->orWhere('name', $adviserIdOrName)
            ->first();

        if ($adviser) {
            $user->adviser_id = $adviser->id;
            if ($user->status === 'unlinked' || $user->hasRole('Student')) {
                $user->status = 'pending';
            }
            $user->save();
        } else if (is_numeric($adviserIdOrName)) {
            $user->adviser_id = (int)$adviserIdOrName;
            if ($user->status === 'unlinked' || $user->hasRole('Student')) {
                $user->status = 'pending';
            }
            $user->save();
        }

        return $user->fresh(['department', 'batch', 'section', 'adviser', 'roles']);
    }

    public function assignSections(User $user, array $sectionIds): User
    {
        $this->userRepository->assignSectionsToUser($user, $sectionIds);
        return $user->fresh(['assignedSections']);
    }

    public function updateCrStatus(User $user, bool $isCr): User
    {
        $this->userRepository->update($user->id, ['is_cr' => $isCr]);
        if ($isCr) {
            $user->assignRole('Class Representative');
        } else {
            $user->removeRole('Class Representative');
        }
        return $user->fresh(['roles']);
    }
}
