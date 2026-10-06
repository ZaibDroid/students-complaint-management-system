<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (Schema::hasTable('password_reset_tokens')) {
            Schema::table('password_reset_tokens', function (Blueprint $table) {
                if (config('database.default') !== 'sqlite' && config('database.connections.' . config('database.default') . '.driver') !== 'sqlite') {
                    $table->string('token', 6)->change(); // OTP is 6 digits/characters
                }
                $table->integer('attempts')->default(0)->after('token'); // To limit attempts
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('password_reset_tokens', function (Blueprint $table) {
            $table->string('token')->change();
            $table->dropColumn('attempts');
        });
    }
};
