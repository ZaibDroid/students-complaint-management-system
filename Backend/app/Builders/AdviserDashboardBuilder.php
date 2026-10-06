<?php

namespace App\Builders;

use App\Contracts\Builders\DashboardBuilderInterface;
use App\DTOs\DashboardDTO;
use App\Models\User;
use App\Repositories\Dashboard\AdviserDashboardRepository;
use App\Audit\Repositories\AuditRepository;
use App\Audit\Resources\AuditResource;

class AdviserDashboardBuilder implements DashboardBuilderInterface
{
    protected AdviserDashboardRepository $repository;
    protected AuditRepository $auditRepository;

    public function __construct(AdviserDashboardRepository $repository, AuditRepository $auditRepository)
    {
        $this->repository = $repository;
        $this->auditRepository = $auditRepository;
    }

    public function build(User $user): DashboardDTO
    {
        $dto = new DashboardDTO();
        
        $metrics = $this->repository->getMetrics($user);
        $metrics['unread_notifications'] = $this->repository->getUnreadNotificationsCount($user);
        $dto->metrics = $metrics;

        $dto->recentApplications = $this->repository->getRecentApplications($user)->toArray();
        $dto->recentNotices = $this->repository->getRecentNotices()->toArray();
        $dto->recentActivity = AuditResource::collection($this->auditRepository->forUser($user->id, 10))->response()->getData(true)['data'] ?? [];
        
        return $dto;
    }
}
