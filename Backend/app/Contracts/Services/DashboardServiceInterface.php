<?php

namespace App\Contracts\Services;

use App\Models\User;

interface DashboardServiceInterface
{
    public function getDashboardForUser(User $user): \App\DTOs\DashboardDTO;
    public function getChartsData(string $type, array $filters = []): array;
}
