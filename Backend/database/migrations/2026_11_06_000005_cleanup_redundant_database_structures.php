<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Drop dead tables with 0 rows
        Schema::dropIfExists('media');
        Schema::dropIfExists('login_histories');
        Schema::dropIfExists('notice_targets');

        // 2. Clean up redundant columns on applications
        if (Schema::hasTable('applications')) {
            $cols = [];
            foreach (['attachment_path', 'attachment_name', 'attachment_type', 'attachment_size', 'admin_remarks'] as $col) {
                if (Schema::hasColumn('applications', $col)) {
                    $cols[] = $col;
                }
            }
            if (!empty($cols)) {
                Schema::table('applications', function (Blueprint $table) use ($cols) {
                    $table->dropColumn($cols);
                });
            }
        }

        // 3. Clean up unused column on application_remarks
        if (Schema::hasTable('application_remarks') && Schema::hasColumn('application_remarks', 'action_taken')) {
            Schema::table('application_remarks', function (Blueprint $table) {
                $table->dropColumn('action_taken');
            });
        }

        // 4. Clean up redundant year column on users
        if (Schema::hasTable('users') && Schema::hasColumn('users', 'year')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropColumn('year');
            });
        }
    }

    public function down(): void
    {
        // Reversals can re-add nullable columns if rolled back
        if (Schema::hasTable('applications')) {
            Schema::table('applications', function (Blueprint $table) {
                $table->string('attachment_path')->nullable();
                $table->string('attachment_name')->nullable();
                $table->string('attachment_type')->nullable();
                $table->unsignedInteger('attachment_size')->nullable();
                $table->text('admin_remarks')->nullable();
            });
        }

        if (Schema::hasTable('application_remarks')) {
            Schema::table('application_remarks', function (Blueprint $table) {
                $table->string('action_taken')->nullable();
            });
        }

        if (Schema::hasTable('users')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('year')->nullable();
            });
        }

        if (!Schema::hasTable('notice_targets')) {
            Schema::create('notice_targets', function (Blueprint $table) {
                $table->id();
                $table->foreignId('notice_id')->constrained('notices')->onDelete('cascade');
                $table->string('target_type');
                $table->string('target_value')->nullable();
                $table->timestamps();
            });
        }
    }
};

