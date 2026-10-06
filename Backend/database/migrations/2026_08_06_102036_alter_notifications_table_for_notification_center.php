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
        Schema::table('notifications', function (Blueprint $table) {
            $table->dropIndex(['user_id', 'is_read']);
            
            $table->renameColumn('body', 'message');
            $table->dropColumn(['category', 'is_read', 'related_id']);

            $table->string('type')->after('user_id');
            $table->nullableMorphs('reference');
            $table->timestamp('read_at')->nullable();

            $table->index('read_at');
            $table->index(['user_id', 'read_at']);
        });
    }

    public function down(): void
    {
        Schema::table('notifications', function (Blueprint $table) {
            $table->dropIndex(['read_at']);
            $table->dropIndex(['user_id', 'read_at']);
            
            $table->renameColumn('message', 'body');
            $table->dropMorphs('reference');
            $table->dropColumn(['type', 'read_at']);

            $table->string('category')->default('System');
            $table->boolean('is_read')->default(false);
            $table->string('related_id')->nullable();

            $table->index(['user_id', 'is_read']);
        });
    }
};
