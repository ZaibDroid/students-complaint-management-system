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
        Schema::dropIfExists('application_attachments');
        if (Schema::hasColumn('notices', 'attachment_url')) {
            Schema::table('notices', function (Blueprint $table) {
                $table->dropColumn('attachment_url');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // No down migration. Legacy tables are replaced by polymorphic media table.
    }
};
