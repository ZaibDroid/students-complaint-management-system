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
        Schema::table('notices', function (Blueprint $table) {
            $table->string('status')->default('draft')->after('tag');
            $table->timestamp('published_at')->nullable()->after('status');
            $table->timestamp('scheduled_at')->nullable()->after('published_at');
            $table->timestamp('expires_at')->nullable()->after('scheduled_at');
            $table->integer('version')->default(1)->after('expires_at');
            $table->dropColumn('attachment_url');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('notices', function (Blueprint $table) {
            $table->dropColumn(['status', 'published_at', 'scheduled_at', 'expires_at', 'version']);
            $table->string('attachment_url')->nullable();
        });
    }
};
