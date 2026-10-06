<?php

namespace App\Console\Commands;

use App\Models\AuditLog;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;

class PruneAuditLogs extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'audit:prune {--days=365 : The number of days to retain audit logs}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Prune old audit logs based on the retention policy (default: 1 year).';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $days = (int) $this->option('days');
        $date = Carbon::now()->subDays($days);

        $this->info("Pruning audit logs older than {$days} days ({$date->toDateString()})...");

        $count = AuditLog::where('created_at', '<', $date)->delete();

        $this->info("Successfully deleted {$count} old audit logs.");
    }
}
