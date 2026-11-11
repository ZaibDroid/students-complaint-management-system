<?php

namespace Tests\Feature;

use App\Models\Campus;
use App\Models\Department;
use App\Models\Faculty;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RbacSecurityHardeningIntegrationTest extends TestCase
{
    use RefreshDatabase;

    protected Department $dept1;
    protected Department $dept2;
    protected User $coordinator;
    protected User $adviserDept1;
    protected User $adviserDept2;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);

        $campus = Campus::create(['name' => 'Main Campus', 'code' => 'MC']);
        $faculty = Faculty::create(['campus_id' => $campus->id, 'name' => 'Engineering', 'code' => 'ENG']);
        $this->dept1 = Department::create(['faculty_id' => $faculty->id, 'name' => 'Computer Science', 'code' => 'CS']);
        $this->dept2 = Department::create(['faculty_id' => $faculty->id, 'name' => 'Electrical Engineering', 'code' => 'EE']);

        $this->coordinator = User::factory()->create([
            'email' => 'coordinator.cs@uetmardan.edu.pk',
            'department_id' => $this->dept1->id,
            'status' => 'approved',
        ]);
        $this->coordinator->assignRole('Coordinator');

        $this->adviserDept1 = User::factory()->create([
            'email' => 'adviser1.cs@uetmardan.edu.pk',
            'department_id' => $this->dept1->id,
            'status' => 'approved',
        ]);
        $this->adviserDept1->assignRole('Batch Adviser');

        $this->adviserDept2 = User::factory()->create([
            'email' => 'adviser2.ee@uetmardan.edu.pk',
            'department_id' => $this->dept2->id,
            'status' => 'approved',
        ]);
        $this->adviserDept2->assignRole('Batch Adviser');
    }

    public function test_coordinator_cannot_create_admin_or_chairman_account()
    {
        // 1. Attempt to create Admin
        $responseAdmin = $this->actingAs($this->coordinator, 'sanctum')
            ->postJson('/api/v1/users/staff', [
                'name' => 'Fake Admin',
                'email' => 'fake.admin@uetmardan.edu.pk',
                'password' => 'Password123!',
                'role' => 'Admin',
            ]);

        $responseAdmin->assertStatus(422)
            ->assertJsonValidationErrors(['role']);

        // 2. Attempt to create Chairman
        $responseChairman = $this->actingAs($this->coordinator, 'sanctum')
            ->postJson('/api/v1/users/staff', [
                'name' => 'Fake Chairman',
                'email' => 'fake.chairman@uetmardan.edu.pk',
                'password' => 'Password123!',
                'role' => 'Chairman',
            ]);

        $responseChairman->assertStatus(422)
            ->assertJsonValidationErrors(['role']);

        // 3. Permitted: create Batch Adviser in own department
        $responseAdviser = $this->actingAs($this->coordinator, 'sanctum')
            ->postJson('/api/v1/users/staff', [
                'name' => 'Valid Adviser',
                'email' => 'valid.adviser@uetmardan.edu.pk',
                'password' => 'Password123!',
                'role' => 'Batch Adviser',
            ]);

        $responseAdviser->assertStatus(201);
        $this->assertDatabaseHas('users', ['email' => 'valid.adviser@uetmardan.edu.pk', 'department_id' => $this->dept1->id]);
    }

    public function test_coordinator_cannot_create_staff_in_different_department()
    {
        $response = $this->actingAs($this->coordinator, 'sanctum')
            ->postJson('/api/v1/users/staff', [
                'name' => 'Cross Dept Adviser',
                'email' => 'cross.adviser@uetmardan.edu.pk',
                'password' => 'Password123!',
                'role' => 'Batch Adviser',
                'department_id' => $this->dept2->id,
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['department_id']);
    }

    public function test_student_cannot_self_promote_to_cr_during_registration()
    {
        // 1. Passing is_cr: true must be rejected
        $response1 = $this->postJson('/api/v1/auth/register', [
            'name' => 'Hacker Student 1',
            'email' => '23mdbcs111@uetmardan.edu.pk',
            'password' => 'Password123!',
            'is_cr' => true,
        ]);

        $response1->assertStatus(422)
            ->assertJsonValidationErrors(['is_cr']);

        // 2. Passing isCR: true must be rejected
        $response2 = $this->postJson('/api/v1/auth/register', [
            'name' => 'Hacker Student 2',
            'email' => '23mdbcs222@uetmardan.edu.pk',
            'password' => 'Password123!',
            'isCR' => true,
        ]);

        $response2->assertStatus(422)
            ->assertJsonValidationErrors(['isCR']);

        // 3. Normal valid registration succeeds and is_cr is false
        $responseValid = $this->postJson('/api/v1/auth/register', [
            'name' => 'Legit Student',
            'email' => '23mdbcs333@uetmardan.edu.pk',
            'password' => 'Password123!',
            'department_id' => $this->dept1->id,
        ]);

        $responseValid->assertStatus(201);
        $createdUser = User::where('email', '23mdbcs333@uetmardan.edu.pk')->first();
        $this->assertNotNull($createdUser);
        $this->assertFalse((bool)$createdUser->is_cr);
        $this->assertTrue($createdUser->hasRole('Student'));
    }

    public function test_coordinator_cannot_update_or_delete_staff_in_another_department()
    {
        // 1. Attempt to update adviser in Dept 2 -> 403 Forbidden
        $responseUpdate = $this->actingAs($this->coordinator, 'sanctum')
            ->putJson("/api/v1/users/staff/{$this->adviserDept2->id}", [
                'name' => 'Compromised Name',
            ]);

        $responseUpdate->assertStatus(403);

        // 2. Attempt to delete adviser in Dept 2 -> 403 Forbidden
        $responseDelete = $this->actingAs($this->coordinator, 'sanctum')
            ->deleteJson("/api/v1/users/staff/{$this->adviserDept2->id}");

        $responseDelete->assertStatus(403);

        // 3. Permitted: delete adviser in Dept 1 -> 200 OK
        $responseDeleteOwn = $this->actingAs($this->coordinator, 'sanctum')
            ->deleteJson("/api/v1/users/staff/{$this->adviserDept1->id}");

        $responseDeleteOwn->assertStatus(200);
        $this->assertSoftDeleted('users', ['id' => $this->adviserDept1->id]);
    }

    public function test_coordinator_cannot_escalate_staff_role_during_update()
    {
        $response = $this->actingAs($this->coordinator, 'sanctum')
            ->putJson("/api/v1/users/staff/{$this->adviserDept1->id}", [
                'role' => 'Admin',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['role']);
    }
}

