<?php

namespace Tests\Feature;

use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class AuditLogTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Role::firstOrCreate(['name' => 'Student']);
    }

    public function test_login_creates_audit_log()
    {
        $user = User::factory()->create([
            'password' => bcrypt('password123')
        ]);
        $user->assignRole('Student');

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => $user->email,
            'password' => 'password123',
            'device_name' => 'test-device'
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('audit_logs', [
            'user_id' => $user->id,
            'action' => 'UserLoggedIn'
        ]);
    }

    public function test_sensitive_fields_are_masked_in_audit_log()
    {
        $user = User::factory()->create();
        $user->assignRole('Student');

        $this->actingAs($user)->putJson('/api/v1/auth/profile', [
            'phone_number' => '1234567890'
        ]);

        $this->actingAs($user)->putJson('/api/v1/auth/password', [
            'old_password' => 'password',
            'new_password' => 'newpassword123',
            'new_password_confirmation' => 'newpassword123'
        ]);

        $log = AuditLog::where('user_id', $user->id)->latest()->first();

        // Verify password is not in plain text in the audit log
        $this->assertStringNotContainsString('newpassword123', json_encode($log->new_values));
    }
}
