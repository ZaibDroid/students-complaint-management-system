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
        Schema::create('notices', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('content');
            $table->string('target')->default('all'); // all, year, batch, section
            $table->string('target_value')->nullable(); // e.g. "2", "2021-2025", "A"
            $table->foreignId('author_id')->constrained('users')->onDelete('cascade');
            $table->string('author_name');
            $table->string('author_role');
            $table->boolean('is_pinned')->default(false);
            $table->string('attachment_url')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notices');
    }
};
