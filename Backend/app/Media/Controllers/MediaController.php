<?php

namespace App\Media\Controllers;

use App\Http\Controllers\Api\V1\BaseApiController;
use App\Media\Requests\UploadMediaRequest;
use App\Media\Resources\MediaResource;
use App\Media\Services\MediaServiceInterface;
use App\Models\Media;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

class MediaController extends BaseApiController
{
    protected MediaServiceInterface $mediaService;

    public function __construct(MediaServiceInterface $mediaService)
    {
        $this->mediaService = $mediaService;
    }

    public function upload(UploadMediaRequest $request): JsonResponse
    {
        $media = $this->mediaService->upload(
            $request->file('file'),
            $request->input('model_type'),
            (int) $request->input('model_id'),
            $request->user()
        );

        // Here we could dispatch an event: MediaUploaded
        event(new \App\Media\Events\MediaUploaded($media));

        return $this->successResponse(
            new MediaResource($media),
            'File uploaded successfully',
            201
        );
    }

    public function download(Media $media): StreamedResponse
    {
        $this->authorize('view', $media);

        // Dispatch download event
        event(new \App\Media\Events\MediaDownloaded($media));

        return Storage::disk($media->disk)->download(
            $media->path,
            $media->name, // Keep original filename for the user
            ['Content-Type' => $media->mime_type]
        );
    }

    public function destroy(Media $media): JsonResponse
    {
        // Must be the uploader, or an Admin, or have delete permission on the parent model
        if ($media->uploaded_by !== request()->user()->id && !request()->user()->hasRole('Admin')) {
            abort(403, 'Unauthorized to delete this file.');
        }

        $media->delete(); // Soft delete

        event(new \App\Media\Events\MediaDeleted($media));

        return $this->successResponse([], 'File deleted successfully.');
    }
}
