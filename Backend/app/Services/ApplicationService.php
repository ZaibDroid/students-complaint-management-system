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

    public function generateSequentialTicketNumber(?int $year = null): string
    {
        $year = $year ?? (int) date('Y');

        $execute = function () use ($year) {
            $prefix = "DCMS-{$year}-";

            if (\Illuminate\Support\Facades\Schema::hasTable('ticket_sequences')) {
                $seqName = "applications_{$year}";

                // Ensure the sequence record exists
                $exists = DB::table('ticket_sequences')->where('name', $seqName)->exists();
                if (!$exists) {
                    $maxSeq = 0;
                    $existingTickets = Application::withTrashed()
                        ->where('ticket_number', 'LIKE', "{$prefix}%")
                        ->pluck('ticket_number');

                    foreach ($existingTickets as $ticket) {
                        if (preg_match('/-(\d+)$/', $ticket, $matches)) {
                            $num = (int) $matches[1];
                            if ($num > $maxSeq) {
                                $maxSeq = $num;
                            }
                        }
                    }

                    DB::table('ticket_sequences')->insertOrIgnore([
                        'name' => $seqName,
                        'current_value' => $maxSeq,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }

                // Pessimistic locking to serialize concurrent ticket generations
                $seqRow = DB::table('ticket_sequences')
                    ->where('name', $seqName)
                    ->lockForUpdate()
                    ->first();

                $nextVal = ($seqRow ? (int) $seqRow->current_value : 0) + 1;

                DB::table('ticket_sequences')
                    ->where('name', $seqName)
                    ->update([
                        'current_value' => $nextVal,
                        'updated_at' => now(),
                    ]);

                return sprintf('%s%04d', $prefix, $nextVal);
            }

            // Fallback lock query if sequence table is unavailable
            $maxSeq = 0;
            $existingTickets = Application::withTrashed()
                ->where('ticket_number', 'LIKE', "{$prefix}%")
                ->lockForUpdate()
                ->pluck('ticket_number');

            foreach ($existingTickets as $ticket) {
                if (preg_match('/-(\d+)$/', $ticket, $matches)) {
                    $num = (int) $matches[1];
                    if ($num > $maxSeq) {
                        $maxSeq = $num;
                    }
                }
            }

            return sprintf('%s%04d', $prefix, $maxSeq + 1);
        };

        return DB::transactionLevel() > 0 ? $execute() : DB::transaction($execute);
    }

    public function createApplication(User $student, array $data, array $files = []): Application
    {
        $adviserId = $student->adviser_id;
        if (!$adviserId && $student->section_id) {
            $section = \App\Models\Section::find($student->section_id);
            if ($section) {
                $adviser = $section->assignedStaff()
                    ->whereHas('roles', function($q) { $q->whereIn('name', ['Batch Adviser', 'Batch Advisor']); })
                    ->first();
                if (!$adviser) {
                    $adviser = \App\Models\User::where('section_id', $section->id)
                        ->whereHas('roles', function($q) { $q->whereIn('name', ['Batch Adviser', 'Batch Advisor']); })
                        ->first();
                }
                if ($adviser) {
                    $adviserId = $adviser->id;
                    $student->update(['adviser_id' => $adviserId]);
                }
            }
        }

        if (!$adviserId && $student->department_id) {
            $fallbackAdviser = User::where('department_id', $student->department_id)
                ->whereHas('roles', function($q) { $q->whereIn('name', ['Batch Adviser', 'Batch Advisor']); })
                ->first();
            if ($fallbackAdviser) {
                $adviserId = $fallbackAdviser->id;
                $student->update(['adviser_id' => $adviserId]);
            }
        }

        if (!$adviserId) {
            throw new \App\Exceptions\ApiException('No Batch Adviser is assigned to your batch and section yet. Please contact your Department Coordinator.', 422);
        }

        return DB::transaction(function () use ($student, $data, $files, $adviserId) {
            // 1. Concurrency-safe sequential ticket generation
            if (empty($data['ticket_number'])) {
                $data['ticket_number'] = $this->generateSequentialTicketNumber();
            }

            $data['student_id'] = $student->id;
            if (\Illuminate\Support\Facades\Schema::hasColumn('applications', 'department_id')) {
                $data['department_id'] = $student->department_id ?? \App\Models\Department::value('id');
            }
            $data['status'] = 'pending';
            $data['assigned_to_id'] = $adviserId;

            /** @var Application $application */
            $application = $this->repository->create($data);

            // 2. Multi-file attachment handling into application_attachments
            $allFiles = [];
            if (isset($files['attachment']) && $files['attachment'] instanceof UploadedFile) {
                $allFiles[] = $files['attachment'];
            }
            if (isset($files['attachments'])) {
                $attList = is_array($files['attachments']) ? $files['attachments'] : [$files['attachments']];
                foreach ($attList as $file) {
                    if ($file instanceof UploadedFile) {
                        $allFiles[] = $file;
                    }
                }
            }
            foreach ($files as $key => $file) {
                if (is_numeric($key) && $file instanceof UploadedFile) {
                    $allFiles[] = $file;
                }
            }

            foreach ($allFiles as $file) {
                $this->uploadAttachment($application, $file);
            }

            // Dispatch Event after commit
            DB::afterCommit(function () use ($application, $student, $adviserId) {
                event(new ApplicationSubmitted($application, $student, $adviserId ? User::find($adviserId) : null, 'Application submitted by student'));
            });

            return $application->fresh(['student', 'assignedTo', 'department', 'attachments']);
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
            if ($notes !== null && \Illuminate\Support\Facades\Schema::hasColumn('applications', 'admin_remarks')) {
                $updateData['admin_remarks'] = $notes;
            }

            // Automatically create ApplicationRemark entry
            $remarkText = !empty(trim((string)$notes))
                ? trim((string)$notes)
                : "Application forwarded to {$assignTo->name}";

            $remarkData = [
                'application_id' => $lockedApplication->id,
                'user_id' => $actor->id,
                'remark' => $remarkText,
            ];
            if (\Illuminate\Support\Facades\Schema::hasColumn('application_remarks', 'action_taken')) {
                $remarkData['action_taken'] = 'Forwarded';
            }
            $this->remarkRepository->create($remarkData);

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
            if ($notes !== null && \Illuminate\Support\Facades\Schema::hasColumn('applications', 'admin_remarks')) {
                $updateData['admin_remarks'] = $notes;
            }

            // Automatically create ApplicationRemark entry
            $remarkText = !empty(trim((string)$notes))
                ? trim((string)$notes)
                : "Application resolved successfully";

            $remarkData = [
                'application_id' => $lockedApplication->id,
                'user_id' => $actor->id,
                'remark' => $remarkText,
            ];
            if (\Illuminate\Support\Facades\Schema::hasColumn('application_remarks', 'action_taken')) {
                $remarkData['action_taken'] = 'Resolved';
            }
            $this->remarkRepository->create($remarkData);

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
            if ($notes !== null && \Illuminate\Support\Facades\Schema::hasColumn('applications', 'admin_remarks')) {
                $updateData['admin_remarks'] = $notes;
            }

            // Automatically create ApplicationRemark entry
            $remarkText = !empty(trim((string)$notes))
                ? trim((string)$notes)
                : "Application rejected";

            $remarkData = [
                'application_id' => $lockedApplication->id,
                'user_id' => $actor->id,
                'remark' => $remarkText,
            ];
            if (\Illuminate\Support\Facades\Schema::hasColumn('application_remarks', 'action_taken')) {
                $remarkData['action_taken'] = 'Rejected';
            }
            $this->remarkRepository->create($remarkData);

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
            if ($notes !== null && \Illuminate\Support\Facades\Schema::hasColumn('applications', 'admin_remarks')) {
                $updateData['admin_remarks'] = $notes;
            }

            // Automatically create ApplicationRemark entry
            $remarkText = !empty(trim((string)$notes))
                ? trim((string)$notes)
                : "Application returned for corrections";

            $remarkData = [
                'application_id' => $lockedApplication->id,
                'user_id' => $actor->id,
                'remark' => $remarkText,
            ];
            if (\Illuminate\Support\Facades\Schema::hasColumn('application_remarks', 'action_taken')) {
                $remarkData['action_taken'] = 'Returned';
            }
            $this->remarkRepository->create($remarkData);

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
        $remarkData = [
            'application_id' => $application->id,
            'user_id' => $author->id,
            'remark' => $remarkText,
        ];
        if (\Illuminate\Support\Facades\Schema::hasColumn('application_remarks', 'action_taken')) {
            $remarkData['action_taken'] = $actionTaken;
        }

        /** @var ApplicationRemark $remark */
        $remark = $this->remarkRepository->create($remarkData);

        // Notify student of official remark
        if ($author->id !== $application->student_id && $application->student) {
            $this->notificationService->sendApplicationNotification(
                $application->student,
                \App\Enums\NotificationType::ApplicationUpdated,
                $application,
                'New Remark on Application',
                "Official remark added to your Application {$application->ticket_number}."
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

            // 1. Create relational attachment record if table exists
            if (\Illuminate\Support\Facades\Schema::hasTable('application_attachments')) {
                $this->attachmentRepository->create([
                    'application_id' => $application->id,
                    'file_name' => $fileName,
                    'file_path' => $filePath,
                    'file_type' => $fileType,
                    'file_size' => $fileSize,
                ]);
            }

            // 2. Backward-compatible column update if column exists
            if (\Illuminate\Support\Facades\Schema::hasColumn('applications', 'attachment_path')) {
                $this->repository->update($application->id, [
                    'attachment_path' => asset('storage/' . $filePath),
                    'attachment_name' => $fileName,
                    'attachment_type' => $fileType,
                    'attachment_size' => $fileSize,
                ]);
            }
        });
    }

    public function removeAttachment(Application $application): void
    {
        DB::transaction(function () use ($application) {
            foreach ($application->attachments as $att) {
                $path = $att->file_path;
                $att->delete();
                Storage::disk('public')->delete($path);
            }

            if (\Illuminate\Support\Facades\Schema::hasColumn('applications', 'attachment_path')) {
                if ($application->attachment_path) {
                    $relativeStoragePath = str_replace(asset('storage/'), '', $application->attachment_path);
                    Storage::disk('public')->delete($relativeStoragePath);
                }
                $this->repository->update($application->id, [
                    'attachment_path' => null,
                    'attachment_name' => null,
                    'attachment_type' => null,
                    'attachment_size' => null,
                ]);
            }
        });
    }
}
