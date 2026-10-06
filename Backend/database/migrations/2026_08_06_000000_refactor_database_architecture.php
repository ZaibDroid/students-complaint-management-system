<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Users Table
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('is_cr');
            $table->index(['department_id', 'status']);
            $table->index('created_at');
            $table->index('deleted_at');
        });

        // 2. Batches Table
        Schema::table('batches', function (Blueprint $table) {
            $table->unique('name');
            $table->index('start_year');
            $table->index('end_year');
            $table->index('is_active');
            $table->index('created_at');
        });

        // 3. Sections Table
        Schema::table('sections', function (Blueprint $table) {
            $table->dropForeign(['batch_id']);
            $table->foreign('batch_id')->references('id')->on('batches')->restrictOnDelete();
            
            $table->unique(['batch_id', 'name']);
            $table->softDeletes();
            $table->index('created_at');
        });

        // 4. applications Table
        Schema::table('applications', function (Blueprint $table) {
            $table->dropForeign(['student_id']);
            $table->foreign('student_id')->references('id')->on('users')->restrictOnDelete();
            
            $table->index(['category', 'status']);
            $table->index(['priority', 'status']);
            $table->index('created_at');
            $table->index('deleted_at');
        });

        // 5. Notifications Table
        Schema::table('notifications', function (Blueprint $table) {
            $table->index('created_at');
        });

        // 6. Settings Table
        Schema::table('settings', function (Blueprint $table) {
            $table->index('group');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->boolean('is_cr')->default(false);
            $table->dropIndex(['department_id', 'status']);
            $table->dropIndex(['created_at']);
            $table->dropIndex(['deleted_at']);
        });

        Schema::table('batches', function (Blueprint $table) {
            $table->dropUnique(['name']);
            $table->dropIndex(['start_year']);
            $table->dropIndex(['end_year']);
            $table->dropIndex(['is_active']);
            $table->dropIndex(['created_at']);
        });

        Schema::table('sections', function (Blueprint $table) {
            $table->dropForeign(['batch_id']);
            $table->foreign('batch_id')->references('id')->on('batches')->cascadeOnDelete();
            
            $table->dropUnique(['batch_id', 'name']);
            $table->dropSoftDeletes();
            $table->dropIndex(['created_at']);
        });

        Schema::table('applications', function (Blueprint $table) {
            $table->dropForeign(['student_id']);
            $table->foreign('student_id')->references('id')->on('users')->cascadeOnDelete();
            
            $table->dropIndex(['category', 'status']);
            $table->dropIndex(['priority', 'status']);
            $table->dropIndex(['created_at']);
            $table->dropIndex(['deleted_at']);
        });

        Schema::table('notifications', function (Blueprint $table) {
            $table->dropIndex(['created_at']);
        });

        Schema::table('settings', function (Blueprint $table) {
            $table->dropIndex(['group']);
        });
    }
};
