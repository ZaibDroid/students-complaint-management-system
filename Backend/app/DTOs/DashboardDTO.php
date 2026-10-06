<?php

namespace App\DTOs;

class DashboardDTO
{
    public array $metrics = [];
    public array $recentApplications = [];
    public array $recentNotices = [];
    public array $recentNotifications = [];
    public array $recentActivity = [];
    public array $applicationsByStatus = [];
    public array $applicationsByCategory = [];
    public array $applicationsByPriority = [];
    public array $monthlyTrends = [];
    public array $registrationTrends = [];
    public array $staffPerformance = [];
    public ?float $averageResolutionTime = null;

    public function toArray(): array
    {
        return [
            'metrics' => $this->metrics,
            'recent_Applications' => $this->recentApplications,
            'recent_notices' => $this->recentNotices,
            'recent_notifications' => $this->recentNotifications,
            'recent_activity' => $this->recentActivity,
            'by_status' => $this->applicationsByStatus,
            'by_category' => $this->applicationsByCategory,
            'by_priority' => $this->applicationsByPriority,
            'monthly_trends' => $this->monthlyTrends,
            'registration_trends' => $this->registrationTrends,
            'staff_performance' => $this->staffPerformance,
            'average_resolution_time' => $this->averageResolutionTime,
        ];
    }
}
