<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('batches') && !Schema::hasColumn('batches', 'coordinator_id')) {
            Schema::table('batches', function (Blueprint $table) {
                $table->foreignId('coordinator_id')->nullable()->after('department_id')->constrained('users')->nullOnDelete()->index();
            });

            // Backfill coordinator_id from existing users with role 'Coordinator' who have a batch_id
            try {
                $coordinators = DB::table('users')
                    ->join('model_has_roles', 'users.id', '=', 'model_has_roles.model_id')
                    ->join('roles', 'model_has_roles.role_id', '=', 'roles.id')
                    ->where('roles.name', 'Coordinator')
                    ->whereNotNull('users.batch_id')
                    ->select('users.id as coordinator_id', 'users.batch_id')
                    ->get();

                foreach ($coordinators as $coord) {
                    $batchExists = DB::table('batches')->where('id', $coord->batch_id)->exists();
                    if ($batchExists) {
                        $alreadyAssigned = DB::table('batches')->where('id', $coord->batch_id)->whereNotNull('coordinator_id')->exists();
                        if (!$alreadyAssigned) {
                            DB::table('batches')->where('id', $coord->batch_id)->update(['coordinator_id' => $coord->coordinator_id]);
                        }
                    }
                }
            } catch (\Throwable $e) {
                // Ignore backfill errors in fresh test environments where roles/tables might be empty
            }
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('batches') && Schema::hasColumn('batches', 'coordinator_id')) {
            Schema::table('batches', function (Blueprint $table) {
                if (DB::getDriverName() !== 'sqlite') {
                    $table->dropForeign(['coordinator_id']);
                }
                $table->dropColumn('coordinator_id');
            });
        }
    }
};

