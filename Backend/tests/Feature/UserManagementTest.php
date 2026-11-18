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

    public function test_chairman_can_update_coordinator_credentials_including_password_and_batch(): void
    {
        $dept = Department::where('code', 'CS')->first();

        $chairman = User::factory()->create([
            'email' => 'chairman.mgmt@uetmardan.edu.pk',
            'department_id' => $dept->id,
            'status' => 'approved',
        ]);
        $chairman->assignRole('Chairman');

        $coordinator = User::factory()->create([
            'name' => 'Initial Coordinator',
            'email' => 'initial.coord@uetmardan.edu.pk',
            'department_id' => $dept->id,
            'status' => 'approved',
            'password' => \Illuminate\Support\Facades\Hash::make('OldPassword123!'),
        ]);
        $coordinator->assignRole('Coordinator');

        $response = $this->actingAs($chairman, 'sanctum')
            ->putJson("/api/v1/users/staff/{$coordinator->id}", [
                'name' => 'Dr. Updated Coordinator',
                'email' => 'updated.coord@uetmardan.edu.pk',
                'password' => 'NewSecretPassword123!',
                'batch' => '2022-2026',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.name', 'Dr. Updated Coordinator')
            ->assertJsonPath('data.email', 'updated.coord@uetmardan.edu.pk');

        // Confirm database record has updated name and email
        $this->assertDatabaseHas('users', [
            'id' => $coordinator->id,
            'name' => 'Dr. Updated Coordinator',
            'email' => 'updated.coord@uetmardan.edu.pk',
        ]);

        // Confirm batch was resolved and linked in database
        $freshCoordinator = $coordinator->fresh();
        $this->assertNotNull($freshCoordinator->batch_id);

        // Confirm authentication succeeds with the newly updated credentials in database
        $loginResponse = $this->postJson('/api/v1/auth/login', [
            'email' => 'updated.coord@uetmardan.edu.pk',
            'password' => 'NewSecretPassword123!',
        ]);

        $loginResponse->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.id', (string)$coordinator->id);
    }
}
