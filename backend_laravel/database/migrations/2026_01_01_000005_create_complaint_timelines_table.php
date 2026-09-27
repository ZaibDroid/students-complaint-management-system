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
        Schema::create('complaint_timelines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('complaint_id')->constrained('complaints')->onDelete('cascade');
            $table->foreignId('actor_id')->nullable()->constrained('users')->onDelete('set null');
            $table->string('actor_name');
            $table->string('actor_role');
            $table->string('action'); // Submitted, Forwarded, Returned, Resolved, Rejected, RemarkAdded
            $table->string('status_after');
            $table->text('remarks')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('complaint_timelines');
    }
};
