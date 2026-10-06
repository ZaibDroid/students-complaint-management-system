<?php

namespace App\Http\Resources;

use App\DTOs\DashboardDTO;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DashboardResource extends JsonResource
{
    /**
     * @var DashboardDTO
     */
    public $resource;

    public function toArray(Request $request): array
    {
        $user = $request->user();
        
        return [
            $this->mergeWhen($user->hasRole('Student'), [
                'Application_summary' => [
                    'pending' => $this->resource->metrics['pending'] ?? 0,
                    'under_review' => $this->resource->metrics['under_review'] ?? 0,
                    'in_progress' => $this->resource->metrics['in_progress'] ?? 0,
                    'forwarded' => $this->resource->metrics['forwarded'] ?? 0,
                    'resolved' => $this->resource->metrics['resolved'] ?? 0,
                    'rejected' => $this->resource->metrics['rejected'] ?? 0,
                    'returned' => $this->resource->metrics['returned'] ?? 0,
                ],
                'recent_Applications' => ApplicationResource::collection($this->resource->recentApplications ?? []),
                'latest_notices' => NoticeResource::collection($this->resource->recentNotices ?? []),
                'unread_notifications' => $this->resource->metrics['unread_notifications'] ?? 0,
            ]),
            
            $this->mergeWhen($user->hasRole('Batch Adviser'), [
                'assigned_Applications' => $this->resource->metrics['assigned_Applications'] ?? 0,
                'pending_review' => $this->resource->metrics['pending_review'] ?? 0,
                'returned' => $this->resource->metrics['returned'] ?? 0,
                'forwarded' => $this->resource->metrics['forwarded'] ?? 0,
                'recently_resolved' => $this->resource->metrics['recently_resolved'] ?? 0,
                'unread_notifications' => $this->resource->metrics['unread_notifications'] ?? 0,
                'recent_Applications' => ApplicationResource::collection($this->resource->recentApplications ?? []),
                'recent_notices' => NoticeResource::collection($this->resource->recentNotices ?? []),
            ]),

            $this->mergeWhen($user->hasRole('Coordinator'), [
                'metrics' => [
                    'pending_forwarding' => $this->resource->metrics['pending_forwarding'] ?? 0,
                ],
                'by_status' => $this->resource->applicationsByStatus,
                'by_category' => $this->resource->applicationsByCategory,
                'average_resolution_time' => $this->resource->averageResolutionTime,
                'recent_activity' => [
                    'recent_Applications' => ApplicationResource::collection($this->resource->recentApplications ?? []),
                    'recent_notices' => NoticeResource::collection($this->resource->recentNotices ?? []),
                    'recent_notifications' => $this->resource->recentNotifications, // Raw array for now, or NotificationResource
                ],
            ]),

            $this->mergeWhen($user->hasRole('Chairman') || $user->hasRole('Dean'), [
                'department_overview' => $this->resource->metrics,
                'by_status' => $this->resource->applicationsByStatus,
                'by_priority' => $this->resource->applicationsByPriority,
                'by_category' => $this->resource->applicationsByCategory,
                'monthly_trends' => $this->resource->monthlyTrends,
                'staff_performance' => $this->resource->staffPerformance,
            ]),

            $this->mergeWhen($user->hasRole('Admin'), [
                'system_overview' => $this->resource->metrics,
                'registration_trends' => $this->resource->registrationTrends,
                'Application_trends' => $this->resource->monthlyTrends, // Reusing monthlyTrends property for Applications
            ]),
        ];
    }
}
