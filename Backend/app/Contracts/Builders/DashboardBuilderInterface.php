<?php

namespace App\Contracts\Builders;

use App\DTOs\DashboardDTO;
use App\Models\User;

interface DashboardBuilderInterface
{
    public function build(User $user): DashboardDTO;
}
