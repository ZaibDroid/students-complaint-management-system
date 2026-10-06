<?php

namespace App\Services;

use App\Contracts\Repositories\BaseRepositoryInterface;
use App\Contracts\Services\BaseServiceInterface;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Pagination\LengthAwarePaginator;

abstract class BaseService implements BaseServiceInterface
{
    protected BaseRepositoryInterface $repository;

    public function __construct(BaseRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function getAll(array $relations = []): Collection
    {
        return $this->repository->all(['*'], $relations);
    }

    public function getById(int|string $id, array $relations = []): ?Model
    {
        return $this->repository->find($id, ['*'], $relations);
    }

    public function getPaginated(int $perPage = 15, array $relations = [], array $filters = []): LengthAwarePaginator
    {
        return $this->repository->paginate($perPage, ['*'], $relations, $filters);
    }

    public function create(array $data): Model
    {
        return $this->repository->create($data);
    }

    public function update(int|string $id, array $data): bool
    {
        return $this->repository->update($id, $data);
    }

    public function delete(int|string $id): bool
    {
        return $this->repository->delete($id);
    }
}
