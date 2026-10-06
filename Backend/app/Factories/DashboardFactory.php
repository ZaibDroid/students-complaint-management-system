<?php

namespace App\Factories;

use App\Contracts\Builders\DashboardBuilderInterface;
use App\Models\User;
use Illuminate\Support\Facades\App;

class DashboardFactory
{
    public function make(User $user): DashboardBuilderInterface
    {
        if ($user->hasRole('Student')) {
            return App::make(\App\Builders\StudentDashboardBuilder::class);
        }

        if ($user->hasRole('Batch Adviser')) {
            return App::make(\App\Builders\AdviserDashboardBuilder::class);
        }

        if ($user->hasRole('Coordinator')) {
            return App::make(\App\Builders\CoordinatorDashboardBuilder::class);
        }

        if ($user->hasRole('Chairman') || $user->hasRole('Dean')) {
            return App::make(\App\Builders\ChairmanDashboardBuilder::class);
        }

        if ($user->hasRole('Admin')) {
            return App::make(\App\Builders\AdminDashboardBuilder::class);
        }

        // Default to student if no roles match
        return App::make(\App\Builders\StudentDashboardBuilder::class);
    }
}
