<?php

namespace App\Builders;

use App\Contracts\Builders\DashboardBuilderInterface;
use App\DTOs\DashboardDTO;
use App\Models\User;
use App\Repositories\Dashboard\ChairmanDashboardRepository;
use App\Audit\Repositories\AuditRepository;
use App\Audit\Resources\AuditResource;

class ChairmanDashboardBuilder implements DashboardBuilderInterface
{
    protected ChairmanDashboardRepository $repository;
    protected AuditRepository $auditRepository;

    public function __construct(ChairmanDashboardRepository $repository, AuditRepository $auditRepository)
    {
        $this->repository = $repository;
        $this->auditRepository = $auditRepository;
    }

    public function build(User $user): DashboardDTO
    {
        $dto = new DashboardDTO();
        
        $dto->metrics = $this->repository->getMetrics($user);
        $dto->applicationsByStatus = $this->repository->getApplicationsByStatus($user);
        $dto->applicationsByPriority = $this->repository->getApplicationsByPriority($user);
        $dto->applicationsByCategory = $this->repository->getApplicationsByCategory($user);
        $dto->monthlyTrends = $this->repository->getMonthlyTrends($user, request()->get('lastMonths', 6));
        $dto->staffPerformance = $this->repository->getStaffPerformance($user)->toArray();
        $dto->recentActivity = AuditResource::collection($this->auditRepository->forUser($user->id, 10))->response()->getData(true)['data'] ?? [];
        
        return $dto;
    }
}
