<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notice_targets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('notice_id')->constrained('notices')->onDelete('cascade');
            $table->string('target_type'); // e.g. year, batch_id, section_id, role, crs_only
            $table->string('target_value')->nullable(); // e.g. "1st Year", "1", "Student", "true"
            $table->timestamps();

            $table->index(['notice_id', 'target_type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notice_targets');
    }
};
