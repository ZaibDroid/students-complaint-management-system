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
        Schema::create('media', function (Blueprint $table) {
            $table->id();
            
            // Polymorphic relation to any model (Application, Notice, User, etc.)
            $table->morphs('model');
            
            // Storage details
            $table->string('disk')->default('local');
            $table->string('path');
            
            // File Metadata
            $table->string('name'); // Original file name
            $table->string('extension')->nullable();
            $table->string('mime_type');
            $table->unsignedBigInteger('size'); // In bytes
            
            // Deduplication and Verification
            $table->string('hash', 64); // SHA-256
            
            // Optional image/video metadata
            $table->unsignedInteger('width')->nullable();
            $table->unsignedInteger('height')->nullable();
            $table->unsignedInteger('duration')->nullable(); // In seconds for audio/video
            
            // Visibility and Tracking
            $table->string('visibility')->default('private');
            $table->foreignId('uploaded_by')->nullable()->constrained('users')->nullOnDelete();
            
            $table->timestamps();
            $table->softDeletes();
            
            // Indexing for deduplication queries
            $table->unique(['hash', 'size']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('media');
    }
};
