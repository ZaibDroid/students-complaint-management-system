<?php

namespace App\Contracts\Services;

use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Pagination\LengthAwarePaginator;

interface BaseServiceInterface
{
    public function getAll(array $relations = []): Collection;

    public function getById(int|string $id, array $relations = []): ?Model;

    public function getPaginated(int $perPage = 15, array $relations = [], array $filters = []): LengthAwarePaginator;

    public function create(array $data): Model;

    public function update(int|string $id, array $data): bool;

    public function delete(int|string $id): bool;
}
