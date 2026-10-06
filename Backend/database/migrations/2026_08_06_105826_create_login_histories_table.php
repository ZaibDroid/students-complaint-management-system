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
        Schema::create('login_histories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            
            $table->string('ip', 45)->nullable();
            $table->string('device')->nullable(); // e.g. iPhone 13
            $table->string('browser')->nullable();
            $table->string('platform')->nullable(); // e.g. iOS
            
            $table->boolean('success')->default(true);
            $table->string('failure_reason')->nullable();
            
            $table->timestamp('login_at')->useCurrent();
            $table->timestamp('logout_at')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('login_histories');
    }
};
