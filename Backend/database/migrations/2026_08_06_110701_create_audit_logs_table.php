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
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            
            $table->string('action'); // e.g. "ApplicationResolved", "UserLoggedIn"
            $table->nullableMorphs('model'); // model_type, model_id
            
            $table->json('old_values')->nullable();
            $table->json('new_values')->nullable();
            
            $table->string('ip', 45)->nullable();
            $table->string('user_agent')->nullable();
            
            // Audit logs are immutable, so we only need created_at
            $table->timestamp('created_at')->useCurrent();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};
