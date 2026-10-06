<?php

namespace App\Providers;

use App\Contracts\Services\AuthServiceInterface;
use App\Contracts\Services\BatchServiceInterface;
use App\Contracts\Services\ApplicationServiceInterface;
use App\Contracts\Services\DashboardServiceInterface;
use App\Contracts\Services\DepartmentServiceInterface;
use App\Contracts\Services\NoticeServiceInterface;
use App\Contracts\Services\NoticePublishingServiceInterface;
use App\Contracts\Services\NotificationServiceInterface;
use App\Contracts\Services\ReportServiceInterface;
use App\Contracts\Services\SectionServiceInterface;
use App\Contracts\Services\SettingServiceInterface;
use App\Contracts\Services\UserServiceInterface;
use App\Services\AuthService;
use App\Services\BatchService;
use App\Services\ApplicationService;
use App\Services\DashboardService;
use App\Services\DepartmentService;
use App\Services\NoticeService;
use App\Services\NotificationService;
use App\Services\ReportService;
use App\Services\SectionService;
use App\Services\SettingService;
use App\Services\UserService;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;

use App\Events\ApplicationSubmitted;
use App\Events\ApplicationForwarded;
use App\Events\ApplicationResolved;
use App\Events\ApplicationRejected;
use App\Events\ApplicationReturned;
use App\Listeners\CreateTimelineEntry;
use App\Listeners\SendApplicationNotification;
use App\Listeners\ClearDashboardCache;
use App\Events\NoticePublished;
use App\Audit\Listeners\WriteAuditLog;
use App\Auth\Events\UserLoggedIn;
use App\Auth\Events\UserLoggedOut;
use App\Auth\Events\PasswordReset;
use App\Auth\Events\FailedLogin;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(AuthServiceInterface::class, AuthService::class);
        $this->app->bind(UserServiceInterface::class, UserService::class);
        $this->app->bind(DepartmentServiceInterface::class, DepartmentService::class);
        $this->app->bind(BatchServiceInterface::class, BatchService::class);
        $this->app->bind(SectionServiceInterface::class, SectionService::class);
        $this->app->bind(ApplicationServiceInterface::class, ApplicationService::class);
        $this->app->bind(NoticeServiceInterface::class, NoticeService::class);
        $this->app->bind(NoticePublishingServiceInterface::class, \App\Services\NoticePublishingService::class);
        $this->app->bind(NotificationServiceInterface::class, NotificationService::class);
        $this->app->bind(DashboardServiceInterface::class, DashboardService::class);
        $this->app->bind(ReportServiceInterface::class, ReportService::class);
        $this->app->bind(SettingServiceInterface::class, SettingService::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        $this->configureRateLimiting();

        Event::listen(ApplicationSubmitted::class, [CreateTimelineEntry::class, 'handle']);
        Event::listen(ApplicationSubmitted::class, [SendApplicationNotification::class, 'handle']);
        Event::listen(ApplicationSubmitted::class, [ClearDashboardCache::class, 'handle']);
        Event::listen(ApplicationSubmitted::class, [WriteAuditLog::class, 'handle']);

        Event::listen(ApplicationForwarded::class, [CreateTimelineEntry::class, 'handle']);
        Event::listen(ApplicationForwarded::class, [SendApplicationNotification::class, 'handle']);
        Event::listen(ApplicationForwarded::class, [ClearDashboardCache::class, 'handle']);
        Event::listen(ApplicationForwarded::class, [WriteAuditLog::class, 'handle']);

        Event::listen(ApplicationResolved::class, [CreateTimelineEntry::class, 'handle']);
        Event::listen(ApplicationResolved::class, [SendApplicationNotification::class, 'handle']);
        Event::listen(ApplicationResolved::class, [ClearDashboardCache::class, 'handle']);
        Event::listen(ApplicationResolved::class, [WriteAuditLog::class, 'handle']);

        Event::listen(ApplicationRejected::class, [CreateTimelineEntry::class, 'handle']);
        Event::listen(ApplicationRejected::class, [SendApplicationNotification::class, 'handle']);
        Event::listen(ApplicationRejected::class, [ClearDashboardCache::class, 'handle']);
        Event::listen(ApplicationRejected::class, [WriteAuditLog::class, 'handle']);

        Event::listen(ApplicationReturned::class, [CreateTimelineEntry::class, 'handle']);
        Event::listen(ApplicationReturned::class, [SendApplicationNotification::class, 'handle']);
        Event::listen(ApplicationReturned::class, [ClearDashboardCache::class, 'handle']);
        Event::listen(ApplicationReturned::class, [WriteAuditLog::class, 'handle']);

        Event::listen(NoticePublished::class, [ClearDashboardCache::class, 'handle']);
        Event::listen(NoticePublished::class, [WriteAuditLog::class, 'handle']);
        
        // Auth Events
        Event::listen(UserLoggedIn::class, [WriteAuditLog::class, 'handle']);
        Event::listen(UserLoggedOut::class, [WriteAuditLog::class, 'handle']);
        Event::listen(PasswordReset::class, [WriteAuditLog::class, 'handle']);
        Event::listen(FailedLogin::class, [WriteAuditLog::class, 'handle']);
    }

    protected function configureRateLimiting(): void
    {
        RateLimiter::for('login', function (Request $request) {
            return Limit::perMinute(5)->by($request->ip());
        });

        RateLimiter::for('forgot-password', function (Request $request) {
            return Limit::perMinutes(10, 3)->by($request->ip());
        });

        RateLimiter::for('refresh-token', function (Request $request) {
            return Limit::perMinute(30)->by($request->ip());
        });

        RateLimiter::for('otp-verify', function (Request $request) {
            return Limit::perMinute(10)->by($request->ip());
        });
    }
}
