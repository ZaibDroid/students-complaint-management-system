<?php

namespace App\Media\Services;

use App\Models\Media;
use App\Models\User;
use Illuminate\Http\UploadedFile;

interface MediaServiceInterface
{
    /**
     * Upload and attach a file to a model.
     */
    public function upload(UploadedFile $file, string $modelType, int $modelId, User $uploader): Media;

    /**
     * Get the absolute filesystem path for a media record.
     */
    public function getPath(Media $media): string;
}
