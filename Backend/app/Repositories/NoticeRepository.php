<?php

namespace App\Repositories;

use App\Contracts\Repositories\NoticeRepositoryInterface;
use App\Models\Notice;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;

class NoticeRepository extends BaseRepository implements NoticeRepositoryInterface
{
    public function __construct(Notice $model)
    {
        parent::__construct($model);
    }

    public function getNoticesForUser(User $user, array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->model->with(['sender', 'targets', 'attachments']);

        $isElevatedAdmin = $user->hasAnyRole(['Admin', 'Chairman', 'Dean']);

        if (!$isElevatedAdmin) {
            $userRoles = $user->getRoleNames()->toArray();
            if (empty($userRoles)) {
                $userRoles = ['Student'];
            }
            if (in_array('Batch Adviser', $userRoles) && !in_array('Teacher', $userRoles)) {
                $userRoles[] = 'Teacher';
            }

            $userBatchName = $user->batch?->name;
            $userBatchId = $user->batch_id ? (string)$user->batch_id : null;
            $userSectionName = $user->section?->name;
            $userSectionId = $user->section_id ? (string)$user->section_id : null;
            $isCR = (bool)$user->is_cr || $user->hasRole('Class Representative');

            $query->where(function ($mainQ) use ($user, $userRoles, $userBatchName, $userBatchId, $userSectionName, $userSectionId, $isCR) {
                // 1. Author can always see their own notices
                $mainQ->where('sender_id', $user->id)
                      ->orWhere(function ($pubQ) use ($userRoles, $userBatchName, $userBatchId, $userSectionName, $userSectionId, $isCR) {
                          $pubQ->where('status', Notice::STATUS_PUBLISHED);

                          // Case A: Broadcast notices with NO targets at all
                          $pubQ->where(function ($targetFilterQ) use ($userRoles, $userBatchName, $userBatchId, $userSectionName, $userSectionId, $isCR) {
                              $targetFilterQ->whereDoesntHave('targets')
                                            ->orWhere(function ($hasTargetQ) use ($userRoles, $userBatchName, $userBatchId, $userSectionName, $userSectionId, $isCR) {
                                                // Role match
                                                $hasTargetQ->where(function ($roleQ) use ($userRoles) {
                                                    $roleQ->whereDoesntHave('targets', function ($sub) {
                                                        $sub->where('target_type', 'role');
                                                    })->orWhereHas('targets', function ($sub) use ($userRoles) {
                                                        $sub->where('target_type', 'role')
                                                            ->whereIn('target_value', $userRoles);
                                                    });
                                                });

                                                // Batch match (if notice specifies batches)
                                                $hasTargetQ->where(function ($batchQ) use ($userBatchName, $userBatchId) {
                                                    $batchQ->whereDoesntHave('targets', function ($sub) {
                                                        $sub->whereIn('target_type', ['batch', 'batch_id']);
                                                    });
                                                    if ($userBatchName || $userBatchId) {
                                                        $validBatchValues = array_filter([$userBatchName, $userBatchId]);
                                                        $batchQ->orWhereHas('targets', function ($sub) use ($validBatchValues) {
                                                            $sub->whereIn('target_type', ['batch', 'batch_id'])
                                                                ->whereIn('target_value', $validBatchValues);
                                                        });
                                                    }
                                                });

                                                // Section match (if notice specifies sections)
                                                $hasTargetQ->where(function ($secQ) use ($userSectionName, $userSectionId) {
                                                    $secQ->whereDoesntHave('targets', function ($sub) {
                                                        $sub->whereIn('target_type', ['section', 'section_id']);
                                                    });
                                                    if ($userSectionName || $userSectionId) {
                                                        $validSecValues = array_filter([$userSectionName, $userSectionId]);
                                                        $secQ->orWhereHas('targets', function ($sub) use ($validSecValues) {
                                                            $sub->whereIn('target_type', ['section', 'section_id'])
                                                                ->whereIn('target_value', $validSecValues);
                                                        });
                                                    }
                                                });

                                                // CRs only check
                                                if (!$isCR) {
                                                    $hasTargetQ->whereDoesntHave('targets', function ($sub) {
                                                        $sub->where('target_type', 'crs_only')
                                                            ->where('target_value', 'true');
                                                    });
                                                }
                                            });
                          });
                      });
            });
        }

        // Custom search filters
        if (!empty($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%")
                  ->orWhere('tag', 'like', "%{$search}%");
            });
            unset($filters['search']);
        }

        if (!empty($filters) && method_exists($this->model, 'scopeFilter')) {
            $query->filter($filters);
        }

        return $query->latest('created_at')->paginate($perPage);
    }

    public function lockForUpdate(int $id): ?Notice
    {
        return $this->model->whereKey($id)->lockForUpdate()->first();
    }
}
