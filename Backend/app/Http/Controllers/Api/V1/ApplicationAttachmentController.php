<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\ApplicationServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Requests\Application\UploadAttachmentRequest;
use App\Http\Resources\ApplicationAttachmentResource;
use App\Models\Application;
use App\Models\ApplicationAttachment;
use Illuminate\Http\JsonResponse;

class ApplicationAttachmentController extends BaseApiController
{
    protected ApplicationServiceInterface $applicationService;

    public function __construct(ApplicationServiceInterface $applicationService)
    {
        $this->ApplicationService = $applicationService;
    }

    public function store(UploadAttachmentRequest $request, Application $application): JsonResponse
    {
        $this->authorize('update', $application);

        $files = $request->file('attachments');
        if (is_array($files) && count($files) > 0) {
            $this->ApplicationService->uploadAttachment($application, $files[0]);
        }

        return $this->successResponse(
            null,
            'Attachment uploaded successfully'
        );
    }

    public function destroy(Application $application): JsonResponse
    {
        $this->authorize('update', $application);

        $this->ApplicationService->removeAttachment($application);

        return $this->successResponse(null, 'Attachment removed successfully');
    }
}
