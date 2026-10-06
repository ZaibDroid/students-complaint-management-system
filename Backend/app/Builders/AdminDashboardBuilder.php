<?php

namespace App\Builders;

use App\Contracts\Builders\DashboardBuilderInterface;
use App\DTOs\DashboardDTO;
use App\Models\User;
use App\Repositories\Dashboard\AdminDashboardRepository;
use App\Audit\Repositories\AuditRepository;
use App\Audit\Resources\AuditResource;

class AdminDashboardBuilder implements DashboardBuilderInterface
{
    protected AdminDashboardRepository $repository;
    protected AuditRepository $auditRepository;

    public function __construct(AdminDashboardRepository $repository, AuditRepository $auditRepository)
    {
        $this->repository = $repository;
        $this->auditRepository = $auditRepository;
    }

    public function build(User $user): DashboardDTO
    {
        $dto = new DashboardDTO();
        
        $dto->metrics = $this->repository->getSystemStatistics();
        $dto->registrationTrends = $this->repository->getRegistrationTrends(request()->get('lastDays', 30));
        $dto->monthlyTrends = $this->repository->getApplicationTrends(request()->get('lastDays', 30)); 
        
        // Admins can see all latest activity
        $dto->recentActivity = AuditResource::collection($this->auditRepository->latest(10))->response()->getData(true)['data'] ?? [];
        
        return $dto;
    }
}
