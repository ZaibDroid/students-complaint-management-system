<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('applications', function (Blueprint $table) {
            $table->foreignId('category_id')->nullable()->after('description')->constrained('application_categories')->restrictOnDelete();
        });

        Schema::table('applications', function (Blueprint $table) {
            $table->dropIndex(['category', 'status']);
            $table->dropColumn('category');
            
            $table->index(['category_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::table('applications', function (Blueprint $table) {
            $table->string('category')->after('description')->nullable();
        });

        Schema::table('applications', function (Blueprint $table) {
            $table->dropIndex(['category_id', 'status']);
            $table->dropForeign(['category_id']);
            $table->dropColumn('category_id');
            
            $table->index(['category', 'status']);
        });
    }
};
