<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Services\NoticeServiceInterface;
use App\Http\Controllers\Api\BaseApiController;
use App\Http\Requests\Notice\UploadNoticeAttachmentRequest;
use App\Http\Resources\NoticeResource;
use App\Models\Notice;
use Illuminate\Http\JsonResponse;

class NoticeAttachmentController extends BaseApiController
{
    protected NoticeServiceInterface $noticeService;

    public function __construct(NoticeServiceInterface $noticeService)
    {
        $this->noticeService = $noticeService;
    }

    public function upload(UploadNoticeAttachmentRequest $request, Notice $notice): JsonResponse
    {
        $this->authorize('update', $notice);
        
        $attachments = [];
        if ($request->hasFile('attachments')) {
            $attachments = $request->file('attachments');
            if (!is_array($attachments)) {
                $attachments = [$attachments];
            }
        }

        $updatedNotice = $this->noticeService->updateNotice(
            $notice,
            [],
            null,
            $attachments
        );

        return $this->successResponse(new NoticeResource($updatedNotice), 'Notice attachment(s) uploaded successfully');
    }

    public function destroy(Notice $notice, \App\Models\NoticeAttachment $attachment): JsonResponse
    {
        $this->authorize('update', $notice);

        if ($attachment->notice_id !== $notice->id) {
            abort(404, 'Attachment not found for this notice');
        }

        $this->noticeService->deleteAttachment($attachment);

        return $this->successResponse(new NoticeResource($notice->fresh(['sender', 'targets', 'attachments'])), 'Notice attachment removed successfully');
    }
}
