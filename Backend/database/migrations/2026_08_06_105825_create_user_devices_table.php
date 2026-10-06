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
        Schema::create('user_devices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            
            $table->string('device_id')->index(); // Unique hardware ID or UUID from Flutter
            $table->string('device_name')->nullable(); // e.g. "iPhone 13 Pro"
            $table->string('platform')->nullable(); // e.g. "iOS", "Android", "Web"
            $table->string('app_version')->nullable(); 
            
            $table->string('os_version')->nullable(); 
            $table->string('push_token')->nullable(); // For future Firebase integration
            $table->string('ip_address', 45)->nullable();
            
            $table->string('refresh_token_hash', 64)->nullable()->unique(); // Hashed refresh token
            $table->timestamp('refresh_token_expires_at')->nullable();
            
            $table->timestamp('last_used_at')->nullable();
            $table->timestamp('last_login_at')->nullable();
            $table->timestamp('revoked_at')->nullable();
            
            $table->timestamps();
            
            // A user should ideally have unique device IDs, though the same hardware ID might be registered if the app is reinstalled. 
            // We index device_id for fast lookups.
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_devices');
    }
};
