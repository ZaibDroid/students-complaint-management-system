<?php

namespace App\Builders;

use App\Contracts\Builders\DashboardBuilderInterface;
use App\DTOs\DashboardDTO;
use App\Models\User;
use App\Repositories\Dashboard\CoordinatorDashboardRepository;
use App\Audit\Repositories\AuditRepository;
use App\Audit\Resources\AuditResource;

class CoordinatorDashboardBuilder implements DashboardBuilderInterface
{
    protected CoordinatorDashboardRepository $repository;
    protected AuditRepository $auditRepository;

    public function __construct(CoordinatorDashboardRepository $repository, AuditRepository $auditRepository)
    {
        $this->repository = $repository;
        $this->auditRepository = $auditRepository;
    }

    public function build(User $user): DashboardDTO
    {
        $dto = new DashboardDTO();
        
        $dto->metrics = $this->repository->getMetrics($user);
        $dto->applicationsByStatus = $this->repository->getApplicationsByStatus($user);
        $dto->applicationsByCategory = $this->repository->getApplicationsByCategory($user);
        $dto->averageResolutionTime = $this->repository->getAverageResolutionTime($user);
        
        // Populate recent Applications only for coordinator activity
        $dto->recentApplications = $this->repository->getRecentActivity($user)->toArray();
        $dto->recentActivity = AuditResource::collection($this->auditRepository->forUser($user->id, 10))->response()->getData(true)['data'] ?? [];
        
        return $dto;
    }
}
