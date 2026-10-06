<?php

namespace App\Listeners;

use App\Events\ApplicationForwarded;
use App\Events\ApplicationRejected;
use App\Events\ApplicationResolved;
use App\Events\ApplicationReturned;
use App\Events\ApplicationSubmitted;
use App\Events\NoticePublished;
use App\Services\DashboardCacheService;
use Illuminate\Support\Facades\DB;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class ClearDashboardCache implements ShouldQueue
{
    use InteractsWithQueue;
    protected DashboardCacheService $cacheService;

    public function __construct(DashboardCacheService $cacheService)
    {
        $this->cacheService = $cacheService;
    }

    public function handle($event): void
    {
        DB::afterCommit(function () use ($event) {
            if (
                $event instanceof ApplicationSubmitted ||
                $event instanceof ApplicationForwarded ||
                $event instanceof ApplicationResolved ||
                $event instanceof ApplicationRejected ||
                $event instanceof ApplicationReturned
            ) {
                $application = $event->Application;
                
                if ($application->student_id) {
                    $this->cacheService->forgetStudent($application->student_id);
                }
                
                if ($application->assigned_to_id) {
                    $this->cacheService->forgetAdviser($application->assigned_to_id);
                }

                if ($application->student && $application->student->department_id) {
                    $deptId = $application->student->department_id;
                    $this->cacheService->forgetCoordinator($deptId);
                    $this->cacheService->forgetChairman($deptId);
                }

                $this->cacheService->forgetAdmin();
            } elseif ($event instanceof NoticePublished) {
                // For global notices, clear admin
                $this->cacheService->forgetAdmin();
                
                // Detailed parsing of Notice targets to invalidate specific departments/batches 
                // could be done here. For now, since notices can be global, we might need to 
                // accept some delay, or we'd clear everyone. Admin sees it immediately.
            }
        });
    }
}
