<?php

namespace App\Media\Repositories;

use App\Models\Media;

class MediaRepository implements MediaRepositoryInterface
{
    public function findByHashAndSize(string $hash, int $size): ?Media
    {
        return Media::where('hash', $hash)
            ->where('size', $size)
            ->first();
    }

    public function create(array $data): Media
    {
        return Media::create($data);
    }

    public function findById(int $id): ?Media
    {
        return Media::find($id);
    }

    public function delete(Media $media): bool
    {
        return $media->delete(); // Soft delete
    }
}
