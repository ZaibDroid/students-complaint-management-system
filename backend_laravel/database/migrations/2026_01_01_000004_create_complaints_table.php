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
        Schema::create('complaints', function (Blueprint $table) {
            $table->id();
            $table->string('tracking_number')->unique(); // e.g. "DCMS-2026-8942"
            $table->string('title');
            $table->text('description');
            $table->string('category');
            $table->string('status')->default('submitted'); 
            // submitted, under_review, forwarded_to_coordinator, forwarded_to_chairman, forwarded_to_office, forwarded_to_dean, returned, resolved, rejected
            $table->string('priority')->default('medium'); // low, medium, high, urgent
            $table->foreignId('student_id')->constrained('users')->onDelete('cascade');
            $table->string('batch')->nullable();
            $table->string('section')->nullable();
            $table->string('current_handler_role')->default('batch_adviser');
            $table->foreignId('current_handler_id')->nullable()->constrained('users')->onDelete('set null');
            $table->json('attachment_urls')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('complaints');
    }
};
