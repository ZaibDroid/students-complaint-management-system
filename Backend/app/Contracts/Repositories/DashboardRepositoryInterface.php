<?php

namespace App\Contracts\Repositories;

use App\Models\User;

interface DashboardRepositoryInterface
{
    public function getStudentDashboard(User $student): array;

    public function getAdviserDashboard(User $adviser): array;

    public function getCoordinatorDashboard(User $coordinator): array;

    public function getChairmanDashboard(): array;

    public function getAdminDashboard(): array;
}
