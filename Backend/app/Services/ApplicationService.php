<?php

namespace App\Services;

use App\Contracts\Repositories\ApplicationAttachmentRepositoryInterface;
use App\Contracts\Repositories\ApplicationRemarkRepositoryInterface;
use App\Contracts\Repositories\ApplicationRepositoryInterface;
use App\Contracts\Repositories\ApplicationTimelineRepositoryInterface;
use App\Contracts\Services\ApplicationServiceInterface;
use App\Contracts\Services\NotificationServiceInterface;
use App\Models\Application;
use App\Models\ApplicationAttachment;
use App\Models\ApplicationRemark;
use App\Models\User;
use App\Events\ApplicationSubmitted;
use App\Events\ApplicationForwarded;
use App\Events\ApplicationResolved;
use App\Events\ApplicationRejected;
use App\Events\ApplicationReturned;
use Illuminate\Http\UploadedFile;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ApplicationService extends BaseService implements ApplicationServiceInterface
{
    protected ApplicationAttachmentRepositoryInterface $attachmentRepository;
    protected ApplicationRemarkRepositoryInterface $remarkRepository;
    protected ApplicationTimelineRepositoryInterface $timelineRepository;
    protected NotificationServiceInterface $notificationService;

    public function __construct(
        ApplicationRepositoryInterface $repository,
        ApplicationAttachmentRepositoryInterface $attachmentRepository,
        ApplicationRemarkRepositoryInterface $remarkRepository,
        ApplicationTimelineRepositoryInterface $timelineRepository,
        NotificationServiceInterface $notificationService
    ) {
        parent::__construct($repository);
        $this->attachmentRepository = $attachmentRepository;
        $this->remarkRepository = $remarkRepository;
        $this->timelineRepository = $timelineRepository;
        $this->notificationService = $notificationService;
    }

    public function createApplication(User $student, array $data, array $files = []): Application
    {
        $adviserId = $student->adviser_id;
        if (!$adviserId && $student->section_id) {
            $section = \App\Models\Section::find($student->section_id);
            if ($section) {
                $adviser = $section->assignedStaff()
                    ->whereHas('roles', function($q) { $q->where('name', 'Batch Adviser'); })
                    ->first();
                if (!$adviser) {
                    $adviser = \App\Models\User::where('section_id', $section->id)
                        ->whereHas('roles', function($q) { $q->where('name', 'Batch Adviser'); })
                        ->first();
                }
                if ($adviser) {
                    $adviserId = $adviser->id;
                    $student->update(['adviser_id' => $adviserId]);
                }
            }
        }

        if (!$adviserId) {
            throw new \App\Exceptions\ApiException('No Batch Adviser is assigned to your batch and section yet. Please contact your Department Coordinator.', 422);
        }

        return DB::transaction(function () use ($student, $data, $files, $adviserId) {
            $data['student_id'] = $student->id;
            $data['status'] = 'pending';
            $data['assigned_to_id'] = $adviserId;

            /** @var Application $application */
            $application = $this->repository->create($data);

            // Save attachment if provided
            if (isset($files['attachment']) && $files['attachment'] instanceof UploadedFile) {
                $this->uploadAttachment($application, $files['attachment']);
            }

            // Dispatch Event after commit
            DB::afterCommit(function () use ($application, $student, $adviserId) {
                event(new ApplicationSubmitted($application, $student, $adviserId ? User::find($adviserId) : null, 'Application submitted by student'));
            });

            return $application->fresh(['student', 'assignedTo']);
        });
    }

    public function getApplicationsForUser(User $user, array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        /** @var ApplicationRepositoryInterface $repo */
        $repo = $this->repository;
        return $repo->getApplicationsForUser($user, $filters, $perPage);
    }

    public function forward(User $actor, Application $application, User $assignTo, ?string $notes = null): Application
    {
        return DB::transaction(function () use ($actor, $application, $assignTo, $notes) {
            $lockedApplication = $this->repository->lockForUpdate($application->id);
            if (!$lockedApplication->isValidTransition(Application::STATUS_FORWARDED)) {
                throw new \App\Exceptions\ApiException("Invalid status transition to forwarded", 422);
            }

            $updateData = [
                'status' => Application::STATUS_FORWARDED,
                'assigned_to_id' => $assignTo->id,
            ];
            if ($notes !== null) {
                $updateData['admin_remarks'] = $notes;
            }

            $this->repository->update($lockedApplication->id, $updateData);
            
            $lockedApplication->refresh();
            
            DB::afterCommit(function () use ($lockedApplication, $actor, $assignTo, $notes) {
                event(new ApplicationForwarded($lockedApplication, $actor, $assignTo, $notes));
            });

            return $lockedApplication->load(['student', 'assignedTo', 'remarks', 'timeline']);
        });
    }

    public function resolve(User $actor, Application $application, ?string $notes = null): Application
    {
        return DB::transaction(function () use ($actor, $application, $notes) {
            $lockedApplication = $this->repository->lockForUpdate($application->id);
            if (!$lockedApplication->isValidTransition(Application::STATUS_RESOLVED)) {
                throw new \App\Exceptions\ApiException("Invalid status transition to resolved", 422);
            }

            $updateData = ['status' => Application::STATUS_RESOLVED];
            if ($notes !== null) {
                $updateData['admin_remarks'] = $notes;
            }

            $this->repository->update($lockedApplication->id, $updateData);
            
            $lockedApplication->refresh();

            DB::afterCommit(function () use ($lockedApplication, $actor, $notes) {
                event(new ApplicationResolved($lockedApplication, $actor, null, $notes));
            });

            return $lockedApplication->load(['student', 'assignedTo', 'remarks', 'timeline']);
        });
    }

    public function reject(User $actor, Application $application, ?string $notes = null): Application
    {
        return DB::transaction(function () use ($actor, $application, $notes) {
            $lockedApplication = $this->repository->lockForUpdate($application->id);
            if (!$lockedApplication->isValidTransition(Application::STATUS_REJECTED)) {
                throw new \App\Exceptions\ApiException("Invalid status transition to rejected", 422);
            }

            $updateData = ['status' => Application::STATUS_REJECTED];
            if ($notes !== null) {
                $updateData['admin_remarks'] = $notes;
            }

            $this->repository->update($lockedApplication->id, $updateData);
            
            $lockedApplication->refresh();

            DB::afterCommit(function () use ($lockedApplication, $actor, $notes) {
                event(new ApplicationRejected($lockedApplication, $actor, null, $notes));
            });

            return $lockedApplication->load(['student', 'assignedTo', 'remarks', 'timeline']);
        });
    }

    public function returnApplication(User $actor, Application $application, ?string $notes = null): Application
    {
        return DB::transaction(function () use ($actor, $application, $notes) {
            $lockedApplication = $this->repository->lockForUpdate($application->id);
            if (!$lockedApplication->isValidTransition(Application::STATUS_RETURNED)) {
                throw new \App\Exceptions\ApiException("Invalid status transition to returned", 422);
            }

            $updateData = ['status' => Application::STATUS_RETURNED];
            if ($notes !== null) {
                $updateData['admin_remarks'] = $notes;
            }

            $this->repository->update($lockedApplication->id, $updateData);
            
            $lockedApplication->refresh();

            DB::afterCommit(function () use ($lockedApplication, $actor, $notes) {
                event(new ApplicationReturned($lockedApplication, $actor, null, $notes));
            });

            return $lockedApplication->load(['student', 'assignedTo', 'remarks', 'timeline']);
        });
    }

    public function addRemark(User $author, Application $application, string $remarkText, ?string $actionTaken = null): ApplicationRemark
    {
        /** @var ApplicationRemark $remark */
        $remark = $this->remarkRepository->create([
            'application_id' => $application->id,
            'user_id' => $author->id,
            'remark' => $remarkText,
            'action_taken' => $actionTaken,
        ]);

        // Notify student of official remark
        if ($author->id !== $application->student_id) {
            $this->notificationService->sendToUser(
                $application->student_id,
                'New Remark on Application',
                "Official remark added to your Application {$application->ticket_number}.",
                'applications',
                (string)$application->id
            );
        }

        return $remark->load('user');
    }

    public function uploadAttachment(Application $application, UploadedFile $file): void
    {
        DB::transaction(function () use ($application, $file) {
            $fileName = $file->getClientOriginalName();
            $fileType = $file->getClientMimeType();
            $fileSize = $file->getSize();
            $filePath = $file->store("Applications/{$application->id}", 'public');

            $this->repository->update($application->id, [
                'attachment_path' => asset('storage/' . $filePath),
                'attachment_name' => $fileName,
                'attachment_type' => $fileType,
                'attachment_size' => $fileSize,
            ]);
        });
    }

    public function removeAttachment(Application $application): void
    {
        if ($application->attachment_path) {
            DB::transaction(function () use ($application) {
                $relativeStoragePath = str_replace(asset('storage/'), '', $application->attachment_path);

                $this->repository->update($application->id, [
                    'attachment_path' => null,
                    'attachment_name' => null,
                    'attachment_type' => null,
                    'attachment_size' => null,
                ]);

                // Delete file after DB update succeeds
                DB::afterCommit(function () use ($relativeStoragePath) {
                    Storage::disk('public')->delete($relativeStoragePath);
                });
            });
        }
    }
}
