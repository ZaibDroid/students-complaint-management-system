<?php

namespace App\Media\Repositories;

use App\Models\Media;

interface MediaRepositoryInterface
{
    public function findByHashAndSize(string $hash, int $size): ?Media;
    public function create(array $data): Media;
    public function findById(int $id): ?Media;
    public function delete(Media $media): bool;
}
