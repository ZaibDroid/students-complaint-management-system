<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class ProcessNotices extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'notices:process';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Process scheduled and expired notices';

    /**
     * Execute the console command.
     */
    public function handle(\App\Contracts\Services\NoticePublishingServiceInterface $publishingService)
    {
        $this->info('Starting to process notices...');
        $now = now();

        // 1. Publish scheduled notices
        $scheduledNotices = \App\Models\Notice::where('status', \App\Enums\NoticeStatus::Scheduled)
            ->where('scheduled_at', '<=', $now)
            ->get();

        foreach ($scheduledNotices as $notice) {
            $publishingService->publish($notice);
            $this->info("Published notice ID: {$notice->id}");
        }

        // 2. Expire published notices
        $expiredNotices = \App\Models\Notice::where('status', \App\Enums\NoticeStatus::Published)
            ->whereNotNull('expires_at')
            ->where('expires_at', '<=', $now)
            ->get();

        foreach ($expiredNotices as $notice) {
            $publishingService->expire($notice);
            $this->info("Expired notice ID: {$notice->id}");
        }

        $this->info('Finished processing notices.');
    }
}
