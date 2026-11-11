<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Campuses Table
        if (!Schema::hasTable('campuses')) {
            Schema::create('campuses', function (Blueprint $table) {
                $table->id();
                $table->string('name', 150);
                $table->string('code', 50)->unique();
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });

            // Seed default main campus
            DB::table('campuses')->insert([
                'name' => 'Main Campus',
                'code' => 'MAIN',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // 2. Faculties Table
        if (!Schema::hasTable('faculties')) {
            Schema::create('faculties', function (Blueprint $table) {
                $table->id();
                $table->foreignId('campus_id')->constrained('campuses')->onDelete('cascade');
                $table->string('name', 150);
                $table->string('code', 50)->unique();
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });

            $mainCampusId = DB::table('campuses')->where('code', 'MAIN')->value('id') ?? 1;

            // Seed default faculty
            DB::table('faculties')->insert([
                'campus_id' => $mainCampusId,
                'name' => 'Faculty of Electrical and Computing Engineering',
                'code' => 'FECE',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // 3. Add faculty_id to departments if not present
        if (Schema::hasTable('departments') && !Schema::hasColumn('departments', 'faculty_id')) {
            Schema::table('departments', function (Blueprint $table) {
                $table->foreignId('faculty_id')->nullable()->after('id')->constrained('faculties')->onDelete('set null');
            });

            $defaultFacultyId = DB::table('faculties')->where('code', 'FECE')->value('id');
            if ($defaultFacultyId) {
                DB::table('departments')->whereNull('faculty_id')->update(['faculty_id' => $defaultFacultyId]);
            }
        }

        // 4. Add department_id to batches if not present
        if (Schema::hasTable('batches') && !Schema::hasColumn('batches', 'department_id')) {
            Schema::table('batches', function (Blueprint $table) {
                $table->foreignId('department_id')->nullable()->after('id')->constrained('departments')->onDelete('cascade');
                $table->index(['department_id', 'is_active']);
            });

            $defaultDeptId = DB::table('departments')->value('id') ?? 1;
            if ($defaultDeptId) {
                DB::table('batches')->whereNull('department_id')->update(['department_id' => $defaultDeptId]);
            }
        }
    }

    public function down(): void
    {
        if (DB::getDriverName() !== 'sqlite') {
            if (Schema::hasColumn('batches', 'department_id')) {
                Schema::table('batches', function (Blueprint $table) {
                    $table->dropForeign(['department_id']);
                });
            }

            if (Schema::hasColumn('departments', 'faculty_id')) {
                Schema::table('departments', function (Blueprint $table) {
                    $table->dropForeign(['faculty_id']);
                });
            }
        }

        if (Schema::hasColumn('batches', 'department_id')) {
            Schema::table('batches', function (Blueprint $table) {
                $table->dropColumn('department_id');
            });
        }

        if (Schema::hasColumn('departments', 'faculty_id')) {
            Schema::table('departments', function (Blueprint $table) {
                $table->dropColumn('faculty_id');
            });
        }

        Schema::dropIfExists('faculties');
        Schema::dropIfExists('campuses');
    }
};

