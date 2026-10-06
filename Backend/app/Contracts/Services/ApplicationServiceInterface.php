<?php

namespace App\Contracts\Services;

use App\Models\Application;
use App\Models\ApplicationAttachment;
use App\Models\ApplicationRemark;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Pagination\LengthAwarePaginator;

interface ApplicationServiceInterface extends BaseServiceInterface
{
    public function createApplication(User $student, array $data, array $files = []): Application;

    public function getApplicationsForUser(User $user, array $filters = [], int $perPage = 15): LengthAwarePaginator;

    public function forward(User $actor, Application $application, User $assignTo, ?string $notes = null): Application;

    public function resolve(User $actor, Application $application, ?string $notes = null): Application;

    public function reject(User $actor, Application $application, ?string $notes = null): Application;

    public function returnApplication(User $actor, Application $application, ?string $notes = null): Application;
    public function addRemark(User $author, Application $application, string $remarkText, ?string $actionTaken = null): ApplicationRemark;

    public function uploadAttachment(Application $application, UploadedFile $file): void;

    public function removeAttachment(Application $application): void;
}
