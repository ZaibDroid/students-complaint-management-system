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
        Schema::create('adviser_meeting_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('adviser_id')->nullable()->constrained('users')->onDelete('set null');
            $table->text('reason');
            $table->string('status')->default('pending'); // pending, approved, rejected, completed
            $table->string('preferred_slot')->nullable();
            $table->text('adviser_remarks')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('adviser_meeting_requests');
    }
};
