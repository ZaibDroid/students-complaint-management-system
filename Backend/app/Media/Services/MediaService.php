<?php

namespace App\Media\Services;

use App\Media\Repositories\MediaRepositoryInterface;
use App\Models\Media;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class MediaService implements MediaServiceInterface
{
    protected MediaRepositoryInterface $repository;

    public function __construct(MediaRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function upload(UploadedFile $file, string $modelType, int $modelId, User $uploader): Media
    {
        $hash = hash_file('sha256', $file->getRealPath());
        $size = $file->getSize();

        // 1. Deduplication check
        $existingMedia = $this->repository->findByHashAndSize($hash, $size);

        $disk = config('media.disk', 'local');
        $path = $existingMedia ? $existingMedia->path : $this->storeFile($file, $disk);

        // Optional metadata gathering
        $width = null;
        $height = null;
        if (str_starts_with($file->getMimeType(), 'image/')) {
            $dimensions = @getimagesize($file->getRealPath());
            if ($dimensions) {
                $width = $dimensions[0];
                $height = $dimensions[1];
            }
        }

        // 2. Create DB Record
        return $this->repository->create([
            'model_type' => $modelType, // e.g. App\Models\Application
            'model_id' => $modelId,
            'disk' => $disk,
            'path' => $path,
            'name' => $file->getClientOriginalName(),
            'extension' => $file->getClientOriginalExtension(),
            'mime_type' => $file->getMimeType(),
            'size' => $size,
            'hash' => $hash,
            'width' => $width,
            'height' => $height,
            'uploaded_by' => $uploader->id,
            'visibility' => 'private',
        ]);
    }

    public function getPath(Media $media): string
    {
        return Storage::disk($media->disk)->path($media->path);
    }

    protected function storeFile(UploadedFile $file, string $disk): string
    {
        // Example: private/media/2026/08/abcdef123456789.pdf
        $dateFolder = now()->format('Y/m');
        $filename = Str::random(40) . '.' . $file->getClientOriginalExtension();
        $directory = "private/media/{$dateFolder}";

        return $file->storeAs($directory, $filename, $disk);
    }
}
