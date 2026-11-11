<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Create application_attachments if not present
        if (!Schema::hasTable('application_attachments')) {
            Schema::create('application_attachments', function (Blueprint $table) {
                $table->id();
                $table->foreignId('application_id')->constrained('applications')->onDelete('cascade');
                $table->string('file_name');
                $table->string('file_path');
                $table->string('file_type', 100)->nullable();
                $table->unsignedInteger('file_size')->nullable();
                $table->timestamps();

                $table->index('application_id');
            });
        }

        // 2. Add department_id to applications
        if (Schema::hasTable('applications') && !Schema::hasColumn('applications', 'department_id')) {
            Schema::table('applications', function (Blueprint $table) {
                $table->foreignId('department_id')->nullable()->after('ticket_number')->constrained('departments');
                $table->index(['department_id', 'status', 'created_at'], 'app_dept_status_created_idx');
            });

            // Backfill department_id from student's department
            $apps = DB::table('applications')->whereNull('department_id')->get();
            $defaultDeptId = DB::table('departments')->value('id') ?? 1;

            foreach ($apps as $app) {
                $studentDeptId = DB::table('users')->where('id', $app->student_id)->value('department_id');
                DB::table('applications')->where('id', $app->id)->update([
                    'department_id' => $studentDeptId ?? $defaultDeptId,
                ]);
            }
        }

        // 3. Backfill existing single-attachment columns into application_attachments
        if (Schema::hasTable('applications') && Schema::hasColumn('applications', 'attachment_path')) {
            $appsWithFiles = DB::table('applications')->whereNotNull('attachment_path')->get();
            foreach ($appsWithFiles as $app) {
                if (!empty($app->attachment_path)) {
                    $alreadyExists = DB::table('application_attachments')
                        ->where('application_id', $app->id)
                        ->where('file_path', $app->attachment_path)
                        ->exists();

                    if (!$alreadyExists) {
                        DB::table('application_attachments')->insert([
                            'application_id' => $app->id,
                            'file_name' => $app->attachment_name ?? basename($app->attachment_path),
                            'file_path' => $app->attachment_path,
                            'file_type' => $app->attachment_type ?? 'application/octet-stream',
                            'file_size' => $app->attachment_size ?? 0,
                            'created_at' => $app->created_at ?? now(),
                            'updated_at' => $app->updated_at ?? now(),
                        ]);
                    }
                }
            }
        }

        // 4. Backfill any orphaned admin_remarks into application_remarks
        if (Schema::hasTable('applications') && Schema::hasColumn('applications', 'admin_remarks')) {
            $appsWithRemarks = DB::table('applications')->whereNotNull('admin_remarks')->get();
            foreach ($appsWithRemarks as $app) {
                $trimmedRemark = trim($app->admin_remarks);
                if (!empty($trimmedRemark)) {
                    $exists = DB::table('application_remarks')
                        ->where('application_id', $app->id)
                        ->where('remark', $trimmedRemark)
                        ->exists();

                    if (!$exists) {
                        $actorId = $app->assigned_to_id ?? $app->student_id;
                        DB::table('application_remarks')->insert([
                            'application_id' => $app->id,
                            'user_id' => $actorId,
                            'remark' => $trimmedRemark,
                            'created_at' => $app->updated_at ?? now(),
                            'updated_at' => $app->updated_at ?? now(),
                        ]);
                    }
                }
            }
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('applications', 'department_id')) {
            Schema::table('applications', function (Blueprint $table) {
                if (DB::getDriverName() !== 'sqlite') {
                    $table->dropForeign(['department_id']);
                    $table->dropIndex('app_dept_status_created_idx');
                }
                $table->dropColumn('department_id');
            });
        }

        Schema::dropIfExists('application_attachments');
    }
};

