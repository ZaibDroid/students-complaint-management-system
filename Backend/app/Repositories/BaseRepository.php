<?php

namespace App\Repositories;

use App\Contracts\Repositories\BaseRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Pagination\LengthAwarePaginator;

abstract class BaseRepository implements BaseRepositoryInterface
{
    protected Model $model;

    public function __construct(Model $model)
    {
        $this->model = $model;
    }

    public function all(array $columns = ['*'], array $relations = []): Collection
    {
        return $this->model->with($relations)->get($columns);
    }

    public function find(int|string $id, array $columns = ['*'], array $relations = []): ?Model
    {
        return $this->model->with($relations)->find($id, $columns);
    }

    public function findOrFail(int|string $id, array $columns = ['*'], array $relations = []): Model
    {
        return $this->model->with($relations)->findOrFail($id, $columns);
    }

    public function paginate(int $perPage = 15, array $columns = ['*'], array $relations = [], array $filters = []): LengthAwarePaginator
    {
        $query = $this->model->with($relations);

        if (!empty($filters) && method_exists($this->model, 'scopeFilter')) {
            $query->filter($filters);
        }

        return $query->paginate($perPage, $columns);
    }

    public function create(array $payload): Model
    {
        return $this->model->create($payload);
    }

    public function update(int|string $id, array $payload): bool
    {
        $model = $this->findOrFail($id);
        return $model->update($payload);
    }

    public function delete(int|string $id): bool
    {
        $model = $this->findOrFail($id);
        return $model->delete();
    }
}
