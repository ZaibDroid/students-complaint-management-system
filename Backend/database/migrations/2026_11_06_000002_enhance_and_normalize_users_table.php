<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (!Schema::hasColumn('users', 'registration_number')) {
                $table->string('registration_number', 50)->nullable()->unique()->after('email');
            }
            if (!Schema::hasColumn('users', 'current_semester')) {
                $table->unsignedTinyInteger('current_semester')->nullable()->after('section_id');
                $table->index('current_semester');
            }
        });

        // Backfill registration_number from email
        $users = DB::table('users')->whereNull('registration_number')->whereNotNull('email')->get();
        foreach ($users as $user) {
            if (str_contains($user->email, '@')) {
                $derivedRegNo = strtoupper(trim(explode('@', $user->email)[0]));
                if (!empty($derivedRegNo)) {
                    $exists = DB::table('users')->where('registration_number', $derivedRegNo)->where('id', '!=', $user->id)->exists();
                    if (!$exists) {
                        DB::table('users')->where('id', $user->id)->update([
                            'registration_number' => $derivedRegNo,
                        ]);
                    }
                }
            }
        }

        // Backfill current_semester from semester or year column
        $usersToUpdate = DB::table('users')->whereNull('current_semester')->get();
        foreach ($usersToUpdate as $user) {
            $sem = null;
            if (!empty($user->semester) && is_numeric(trim($user->semester))) {
                $sem = (int) trim($user->semester);
            } elseif (!empty($user->semester) && preg_match('/(?:semester|sem)\s*(\d+)/i', $user->semester, $matches)) {
                $sem = (int) $matches[1];
            } elseif (!empty($user->year) && preg_match('/(?:semester|sem)\s*(\d+)/i', $user->year, $matches)) {
                $sem = (int) $matches[1];
            } elseif (!empty($user->year) && is_numeric(trim($user->year))) {
                $val = (int) trim($user->year);
                if ($val >= 1 && $val <= 8) {
                    $sem = $val;
                }
            }

            if ($sem !== null && $sem >= 1 && $sem <= 8) {
                DB::table('users')->where('id', $user->id)->update([
                    'current_semester' => $sem,
                ]);
            }
        }
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (DB::getDriverName() !== 'sqlite') {
                if (Schema::hasColumn('users', 'registration_number')) {
                    $table->dropUnique(['registration_number']);
                }
                if (Schema::hasColumn('users', 'current_semester')) {
                    $table->dropIndex(['current_semester']);
                }
            }
            if (Schema::hasColumn('users', 'registration_number')) {
                $table->dropColumn('registration_number');
            }
            if (Schema::hasColumn('users', 'current_semester')) {
                $table->dropColumn('current_semester');
            }
        });
    }
};

