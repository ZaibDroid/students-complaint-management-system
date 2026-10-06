<?php

namespace Tests\Feature;

use App\Models\Department;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserManagementTest extends TestCase
{
    use RefreshDatabase;

    protected User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);

        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        $this->admin = User::factory()->create([
            'email' => 'admin.mgmt@uetmardan.edu.pk',
            'department_id' => $dept->id,
            'status' => 'approved',
        ]);
        $this->admin->assignRole('Admin');
    }

    public function test_admin_can_create_staff_user(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->postJson('/api/v1/users/staff', [
                'name' => 'New Batch Adviser',
                'email' => 'new.adviser@uetmardan.edu.pk',
                'password' => 'Password123!',
                'password_confirmation' => 'Password123!',
                'role' => 'Batch Adviser',
                'department_id' => $this->admin->department_id,
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true);

        $this->assertDatabaseHas('users', [
            'email' => 'new.adviser@uetmardan.edu.pk',
        ]);
    }

    public function test_admin_can_list_users(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->getJson('/api/v1/users');

        $response->assertStatus(200)
            ->assertJsonPath('success', true);
    }
}
