<?php

namespace App\Services;

use App\Contracts\Repositories\UserRepositoryInterface;
use App\Contracts\Services\UserServiceInterface;
use App\Exceptions\ApiException;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

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

        $batch = null;
        if (!empty($data['batch_id']) && is_numeric($data['batch_id'])) {
            $batch = \App\Models\Batch::find((int)$data['batch_id']);
        }

        if (!$batch && $batchName !== null && $batchName !== '') {
            $rawStr = trim((string)$batchName);
            $batchYear = 0;
            $startYear = null;
            $endYear = null;

            if (preg_match('#(20\d{2})\s*[-–—/]\s*(20\d{2})#', $rawStr, $rangeMatches)) {
                $startYear = (int)$rangeMatches[1];
                $endYear = (int)$rangeMatches[2];
                $batchYear = $startYear;
            } else if (is_numeric($rawStr)) {
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

            $canonicalName = ($startYear && $endYear) ? "{$startYear}-{$endYear}" : (is_numeric($rawStr) ? (string)$batchYear : $rawStr);

            $batch = \App\Models\Batch::where('name', (string)$batchYear)
                ->orWhere('name', $canonicalName)
                ->orWhere('name', $rawStr)
                ->orWhere('name', 'Batch ' . $canonicalName)
                ->orWhere('name', 'Batch ' . $rawStr)
                ->orWhere(function ($q) use ($startYear, $endYear) {
                    if ($startYear && $endYear) {
                        $q->where('start_year', $startYear)->where('end_year', $endYear);
                    }
                })
                ->orWhere('start_year', $batchYear)
                ->first();

            if (!$batch) {
                $batchDeptId = $data['department_id'] ?? \App\Models\Department::first()?->id;
                $batch = \App\Models\Batch::create([
                    'name' => $canonicalName,
                    'start_year' => $startYear ?: $batchYear,
                    'end_year' => $endYear ?: ($batchYear + 4),
                    'department_id' => $batchDeptId,
                ]);
            }
        }

        if ($batch) {
            $data['batch_id'] = $batch->id;

            if (!empty($data['section_id']) && is_numeric($data['section_id'])) {
                $section = \App\Models\Section::withTrashed()->where('id', (int)$data['section_id'])->first();
                if ($section && (int)$section->batch_id === (int)$batch->id) {
                    if ($section->trashed()) {
                        $section->restore();
                    }
                    $data['section_id'] = $section->id;
                    return $section->id;
                }
            }

            if ($sectionName !== null && $sectionName !== '') {
                $secName = strtoupper(trim((string)$sectionName));
                $shortSec = str_ireplace('SECTION ', '', $secName);
                $longSec = 'Section ' . $shortSec;

                $section = \App\Models\Section::withTrashed()
                    ->where('batch_id', $batch->id)
                    ->where(function ($q) use ($secName, $shortSec, $longSec) {
                        $q->where('name', $secName)
                          ->orWhere('name', $shortSec)
                          ->orWhere('name', $longSec);
                    })
                    ->first();

                if ($section && $section->trashed()) {
                    $section->restore();
                }

                if (!$section) {
                    $section = \App\Models\Section::create([
                        'batch_id' => $batch->id,
                        'name' => $shortSec,
                    ]);
                }
                $data['section_id'] = $section->id;
                return $section->id;
            }
        }
        return null;
    }

    public function createStaff(array $data): User
    {
        return DB::transaction(function () use ($data) {
            if (isset($data['password'])) {
                $data['assigned_password'] = $data['password'];
            }
            $data['password'] = Hash::make($data['password']);
            $data['status'] = 'approved';

            $role = $data['role'] ?? 'Office Staff';
            unset($data['role']);

            if (empty($data['department_id'])) {
                $data['department_id'] = \App\Models\Department::first()?->id ?? 1;
            }

            $assignedSections = $data['assigned_sections'] ?? [];
            unset($data['assigned_sections']);

            $isCoordinator = ($role === 'Coordinator');
            $createdSectionId = $this->resolveBatchAndSection($data);

            if ($isCoordinator && !empty($data['batch_id'])) {
                $targetBatch = \App\Models\Batch::where('id', $data['batch_id'])->lockForUpdate()->first();
                if ($targetBatch && $targetBatch->coordinator_id !== null) {
                    throw ValidationException::withMessages([
                        'batch_id' => ['This batch is already assigned to another coordinator.'],
                    ]);
                }
            }

            /** @var User $user */
            $user = $this->userRepository->create($data);
            $user->assignRole($role);

            if ($isCoordinator && !empty($data['batch_id'])) {
                \App\Models\Batch::where('id', $data['batch_id'])->update(['coordinator_id' => $user->id]);
            }

            $resolvedSectionIds = [];
            if ($createdSectionId) {
                $resolvedSectionIds[] = $createdSectionId;
            }

            if (!empty($assignedSections) && is_array($assignedSections)) {
                foreach ($assignedSections as $item) {
                    if (is_numeric($item)) {
                        $resolvedSectionIds[] = (int)$item;
                    } elseif (is_array($item)) {
                        $itemCopy = $item;
                        $secId = $this->resolveBatchAndSection($itemCopy);
                        if ($secId) {
                            $resolvedSectionIds[] = $secId;
                        } elseif (!empty($item['section_id']) && is_numeric($item['section_id'])) {
                            $resolvedSectionIds[] = (int)$item['section_id'];
                        }
                    }
                }
            }

            $resolvedSectionIds = array_values(array_unique(array_filter($resolvedSectionIds)));
            if (!empty($resolvedSectionIds)) {
                $user->assignedSections()->sync($resolvedSectionIds);

                if (in_array($role, ['Batch Adviser', 'Batch Advisor'], true)) {
                    foreach ($resolvedSectionIds as $sId) {
                        \App\Models\Section::where('id', $sId)->first()?->assignedStaff()->sync([$user->id]);
                    }
                }
            }

            return $user->load(['department', 'batch', 'section', 'roles', 'assignedSections.batch']);
        });
    }

    public function updateStaff(User $user, array $data): User
    {
        return DB::transaction(function () use ($user, $data) {
            if (isset($data['password']) && !empty($data['password'])) {
                $data['assigned_password'] = $data['password'];
                $data['password'] = Hash::make($data['password']);
            } else {
                unset($data['password']);
            }

            $effectiveRole = isset($data['role']) ? $data['role'] : ($user->roles->first()?->name ?? '');
            if (isset($data['role'])) {
                $user->syncRoles([$data['role']]);
                unset($data['role']);
            }

            $assignedSections = $data['assigned_sections'] ?? null;
            unset($data['assigned_sections']);

            $isCoordinator = ($effectiveRole === 'Coordinator');
            $createdSectionId = $this->resolveBatchAndSection($data);

            if ($isCoordinator) {
                if (array_key_exists('batch_ids', $data) && is_array($data['batch_ids'])) {
                    $targetBatchIds = array_filter(array_map('intval', $data['batch_ids']));
                    unset($data['batch_ids']);

                    foreach ($targetBatchIds as $bId) {
                        $tb = \App\Models\Batch::where('id', $bId)->lockForUpdate()->first();
                        if ($tb && $tb->coordinator_id !== null && (int)$tb->coordinator_id !== (int)$user->id) {
                            throw ValidationException::withMessages([
                                'batch_id' => ["Batch {$tb->name} is already assigned to another coordinator."],
                            ]);
                        }
                    }
                    // Release batches not in the new list
                    \App\Models\Batch::where('coordinator_id', $user->id)->whereNotIn('id', $targetBatchIds)->update(['coordinator_id' => null]);
                    // Assign new batches
                    if (!empty($targetBatchIds)) {
                        \App\Models\Batch::whereIn('id', $targetBatchIds)->update(['coordinator_id' => $user->id]);
                        $data['batch_id'] = $targetBatchIds[0];
                    } else {
                        $data['batch_id'] = null;
                    }
                } elseif (array_key_exists('batch_id', $data)) {
                    $newBatchId = $data['batch_id'];
                    if (!empty($newBatchId)) {
                        $targetBatch = \App\Models\Batch::where('id', $newBatchId)->lockForUpdate()->first();
                        if ($targetBatch && $targetBatch->coordinator_id !== null && (int)$targetBatch->coordinator_id !== (int)$user->id) {
                            throw ValidationException::withMessages([
                                'batch_id' => ['This batch is already assigned to another coordinator.'],
                            ]);
                        }
                        $keepExisting = !empty($data['keep_existing_batches']);
                        unset($data['keep_existing_batches']);
                        if (!$keepExisting) {
                            \App\Models\Batch::where('coordinator_id', $user->id)->where('id', '!=', $newBatchId)->update(['coordinator_id' => null]);
                        }
                        if ($targetBatch) {
                            $targetBatch->update(['coordinator_id' => $user->id]);
                        }
                    } else {
                        // Batch released
                        \App\Models\Batch::where('coordinator_id', $user->id)->update(['coordinator_id' => null]);
                    }
                }
            } else {
                // If role changed from Coordinator to another role, release any coordinator batch
                \App\Models\Batch::where('coordinator_id', $user->id)->update(['coordinator_id' => null]);
            }

            $this->userRepository->update($user->id, $data);

            $resolvedSectionIds = [];
            if ($createdSectionId) {
                $resolvedSectionIds[] = $createdSectionId;
            }

            if ($assignedSections !== null && is_array($assignedSections)) {
                foreach ($assignedSections as $item) {
                    if (is_numeric($item)) {
                        $resolvedSectionIds[] = (int)$item;
                    } elseif (is_array($item)) {
                        $itemCopy = $item;
                        $secId = $this->resolveBatchAndSection($itemCopy);
                        if ($secId) {
                            $resolvedSectionIds[] = $secId;
                        } elseif (!empty($item['section_id']) && is_numeric($item['section_id'])) {
                            $resolvedSectionIds[] = (int)$item['section_id'];
                        }
                    }
                }
                $resolvedSectionIds = array_values(array_unique(array_filter($resolvedSectionIds)));
                $user->assignedSections()->sync($resolvedSectionIds);
            } elseif (!empty($resolvedSectionIds)) {
                $user->assignedSections()->syncWithoutDetaching($resolvedSectionIds);
            }

            return $user->fresh(['department', 'batch', 'section', 'roles', 'assignedSections.batch']);
        });
    }

    public function deleteStaff(User $user): void
    {
        \App\Models\Batch::where('coordinator_id', $user->id)->update(['coordinator_id' => null]);
        $user->tokens()->delete();
        if (method_exists($user, 'roles')) {
            $user->roles()->detach();
        }
        $user->forceDelete();
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
        $hasCoordinator = in_array('Coordinator', $roles, true);
        $hadCoordinator = $user->hasRole('Coordinator');

        if ($hadCoordinator && !$hasCoordinator) {
            \App\Models\Batch::where('coordinator_id', $user->id)->update(['coordinator_id' => null]);
        }

        $user->syncRoles($roles);
        return $user->fresh(['roles']);
    }

    public function assignAdviser(User $user, int|string $adviserIdOrName): User
    {
        $adviser = User::where('id', $adviserIdOrName)
            ->orWhere('name', $adviserIdOrName)
            ->first();

        if ($adviser) {
            // If the user being linked is a Student, ensure the adviser actually matches the student's batch!
            if ($user->hasRole('Student') && $user->batch_id) {
                $matchesBatch = false;

                // 1. Direct batch match
                if ($adviser->batch_id && (int)$adviser->batch_id === (int)$user->batch_id) {
                    $matchesBatch = true;
                }

                // 2. Assigned sections match
                if (!$matchesBatch && $adviser->assignedSections()->where('batch_id', $user->batch_id)->exists()) {
                    $matchesBatch = true;
                }

                // 3. Batch start year match (in case batch records share the same start year)
                if (!$matchesBatch) {
                    $studentBatch = $user->batch ?? \App\Models\Batch::find($user->batch_id);
                    if ($studentBatch && $studentBatch->start_year) {
                        $adviserBatchIds = $adviser->assignedSections()->pluck('batch_id')->filter()->toArray();
                        if ($adviser->batch_id) {
                            $adviserBatchIds[] = $adviser->batch_id;
                        }
                        if (!empty($adviserBatchIds)) {
                            $matchesBatch = \App\Models\Batch::whereIn('id', $adviserBatchIds)
                                ->where('start_year', $studentBatch->start_year)
                                ->exists();
                        }
                    }
                }

                if (!$matchesBatch) {
                    $batchName = $user->batch?->name ?? 'your batch';
                    throw new ApiException("The selected adviser ({$adviser->name}) is not assigned to {$batchName}. Please select your batch adviser.", 422);
                }
            }

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
