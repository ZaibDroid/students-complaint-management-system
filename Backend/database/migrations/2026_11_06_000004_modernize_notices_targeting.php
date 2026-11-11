<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('notices')) {
            Schema::table('notices', function (Blueprint $table) {
                if (!Schema::hasColumn('notices', 'department_id')) {
                    $table->foreignId('department_id')->nullable()->after('id')->constrained('departments')->onDelete('set null');
                }
                if (!Schema::hasColumn('notices', 'target_batch_id')) {
                    $table->foreignId('target_batch_id')->nullable()->after('sender_id')->constrained('batches')->onDelete('set null');
                }
                if (!Schema::hasColumn('notices', 'target_section_id')) {
                    $table->foreignId('target_section_id')->nullable()->after('target_batch_id')->constrained('sections')->onDelete('set null');
                }
                if (!Schema::hasColumn('notices', 'target_role')) {
                    $table->string('target_role', 50)->nullable()->after('target_section_id');
                }

                $table->index(['department_id', 'status', 'published_at'], 'notices_dept_status_pub_idx');
                $table->index(['target_batch_id', 'target_section_id'], 'notices_batch_sec_idx');
            });

            // Backfill department_id from sender
            $notices = DB::table('notices')->whereNull('department_id')->get();
            foreach ($notices as $notice) {
                $senderDept = DB::table('users')->where('id', $notice->sender_id)->value('department_id');
                if ($senderDept) {
                    DB::table('notices')->where('id', $notice->id)->update(['department_id' => $senderDept]);
                }
            }

            // Backfill targeting from notice_targets if it exists
            if (Schema::hasTable('notice_targets')) {
                $targets = DB::table('notice_targets')->get();
                foreach ($targets as $target) {
                    $update = [];
                    if ($target->target_type === 'department_id' && is_numeric($target->target_value)) {
                        $update['department_id'] = (int)$target->target_value;
                    } elseif ($target->target_type === 'batch_id' && is_numeric($target->target_value)) {
                        $update['target_batch_id'] = (int)$target->target_value;
                    } elseif ($target->target_type === 'section_id' && is_numeric($target->target_value)) {
                        $update['target_section_id'] = (int)$target->target_value;
                    } elseif ($target->target_type === 'crs_only') {
                        $update['target_role'] = 'CR';
                    }

                    if (!empty($update)) {
                        DB::table('notices')->where('id', $target->notice_id)->update($update);
                    }
                }
            }
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('notices')) {
            Schema::table('notices', function (Blueprint $table) {
                if (DB::getDriverName() !== 'sqlite') {
                    $table->dropIndex('notices_dept_status_pub_idx');
                    $table->dropIndex('notices_batch_sec_idx');
                    if (Schema::hasColumn('notices', 'target_batch_id')) {
                        $table->dropForeign(['target_batch_id']);
                    }
                    if (Schema::hasColumn('notices', 'target_section_id')) {
                        $table->dropForeign(['target_section_id']);
                    }
                    if (Schema::hasColumn('notices', 'department_id')) {
                        $table->dropForeign(['department_id']);
                    }
                }
                if (Schema::hasColumn('notices', 'target_batch_id')) {
                    $table->dropColumn('target_batch_id');
                }
                if (Schema::hasColumn('notices', 'target_section_id')) {
                    $table->dropColumn('target_section_id');
                }
                if (Schema::hasColumn('notices', 'department_id')) {
                    $table->dropColumn('department_id');
                }
                if (Schema::hasColumn('notices', 'target_role')) {
                    $table->dropColumn('target_role');
                }
            });
        }
    }
};

