<?php

namespace App\Providers;

use App\Contracts\Repositories\BatchRepositoryInterface;
use App\Contracts\Repositories\ApplicationAttachmentRepositoryInterface;
use App\Contracts\Repositories\ApplicationRemarkRepositoryInterface;
use App\Contracts\Repositories\ApplicationRepositoryInterface;
use App\Contracts\Repositories\ApplicationTimelineRepositoryInterface;
use App\Contracts\Repositories\DashboardRepositoryInterface;
use App\Contracts\Repositories\DepartmentRepositoryInterface;
use App\Contracts\Repositories\NoticeRepositoryInterface;
use App\Contracts\Repositories\NoticeTargetRepositoryInterface;
use App\Contracts\Repositories\NotificationRepositoryInterface;
use App\Contracts\Repositories\ReportRepositoryInterface;
use App\Contracts\Repositories\SectionRepositoryInterface;
use App\Contracts\Repositories\SettingRepositoryInterface;
use App\Contracts\Repositories\UserRepositoryInterface;
use App\Repositories\BatchRepository;
use App\Repositories\ApplicationAttachmentRepository;
use App\Repositories\ApplicationRemarkRepository;
use App\Repositories\ApplicationRepository;
use App\Repositories\ApplicationTimelineRepository;
use App\Repositories\DashboardRepository;
use App\Repositories\DepartmentRepository;
use App\Repositories\NoticeRepository;
use App\Repositories\NoticeTargetRepository;
use App\Repositories\NotificationRepository;
use App\Repositories\ReportRepository;
use App\Repositories\SectionRepository;
use App\Repositories\SettingRepository;
use App\Repositories\UserRepository;
use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    /**
     * Register Interface-to-Implementation Repository Bindings.
     */
    public function register(): void
    {
        $this->app->bind(UserRepositoryInterface::class, UserRepository::class);
        $this->app->bind(DepartmentRepositoryInterface::class, DepartmentRepository::class);
        $this->app->bind(BatchRepositoryInterface::class, BatchRepository::class);
        $this->app->bind(SectionRepositoryInterface::class, SectionRepository::class);
        $this->app->bind(ApplicationRepositoryInterface::class, ApplicationRepository::class);
        $this->app->bind(ApplicationAttachmentRepositoryInterface::class, ApplicationAttachmentRepository::class);
        $this->app->bind(ApplicationRemarkRepositoryInterface::class, ApplicationRemarkRepository::class);
        $this->app->bind(ApplicationTimelineRepositoryInterface::class, ApplicationTimelineRepository::class);
        $this->app->bind(NoticeRepositoryInterface::class, NoticeRepository::class);
        $this->app->bind(NoticeTargetRepositoryInterface::class, NoticeTargetRepository::class);
        $this->app->bind(NotificationRepositoryInterface::class, NotificationRepository::class);
        $this->app->bind(DashboardRepositoryInterface::class, DashboardRepository::class);
        $this->app->bind(ReportRepositoryInterface::class, ReportRepository::class);
        $this->app->bind(SettingRepositoryInterface::class, SettingRepository::class);
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
}
