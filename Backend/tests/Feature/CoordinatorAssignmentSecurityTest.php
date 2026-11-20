<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\ApplicationCategory;
use App\Models\Batch;
use App\Models\Department;
use App\Models\Section;
use App\Models\User;
use App\Repositories\ApplicationRepository;
use App\Services\UserService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Gate;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class CoordinatorAssignmentSecurityTest extends TestCase
{
    use RefreshDatabase;

    protected Department $department;
    protected Batch $batch2021;
    protected Batch $batch2022;
    protected Batch $batch2023;
    protected Section $section2021A;
    protected Section $section2022A;
    protected User $chairman;
    protected User $coordinatorA;
    protected User $coordinatorB;
    protected User $adviser;
    protected User $student2021;
    protected ApplicationCategory $category;
    protected Application $complaint2021;
    protected Application $complaint2022;

    protected function setUp(): void
    {
        parent::setUp();

        // 1. Roles
        foreach (['Admin', 'Chairman', 'Coordinator', 'Batch Adviser', 'Batch Advisor', 'Student', 'Office Staff'] as $roleName) {
            Role::firstOrCreate(['name' => $roleName, 'guard_name' => 'web']);
            Role::firstOrCreate(['name' => $roleName, 'guard_name' => 'api']);
        }

        // 2. Department & Batches
        $this->department = Department::create(['name' => 'Computer Science & IT', 'code' => 'CSIT']);

        $this->batch2021 = Batch::create([
            'department_id' => $this->department->id,
            'name' => '2021-2025',
            'start_year' => 2021,
            'end_year' => 2025,
            'is_active' => true,
        ]);

        $this->batch2022 = Batch::create([
            'department_id' => $this->department->id,
            'name' => '2022-2026',
            'start_year' => 2022,
            'end_year' => 2026,
            'is_active' => true,
        ]);

        $this->batch2023 = Batch::create([
            'department_id' => $this->department->id,
            'name' => '2023-2027',
            'start_year' => 2023,
            'end_year' => 2027,
            'is_active' => true,
        ]);

        // 3. Sections
        $this->section2021A = Section::create([
            'batch_id' => $this->batch2021->id,
            'name' => 'A',
            'is_active' => true,
        ]);

        $this->section2022A = Section::create([
            'batch_id' => $this->batch2022->id,
            'name' => 'A',
            'is_active' => true,
        ]);

        // 4. Chairman
        $this->chairman = User::create([
            'name' => 'Dr. Chairman CS',
            'email' => 'chairman.cs@uetmardan.edu.pk',
            'password' => bcrypt('password123'),
            'department_id' => $this->department->id,
            'status' => 'approved',
        ]);
        $this->chairman->assignRole('Chairman');

        // 5. Coordinator A assigned to Batch 2021
        $this->coordinatorA = User::create([
            'name' => 'Prof. Coordinator A',
            'email' => 'coordinator.a@uetmardan.edu.pk',
            'password' => bcrypt('password123'),
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'status' => 'approved',
        ]);
        $this->coordinatorA->assignRole('Coordinator');
        $this->batch2021->update(['coordinator_id' => $this->coordinatorA->id]);

        // 6. Coordinator B assigned to Batch 2022
        $this->coordinatorB = User::create([
            'name' => 'Prof. Coordinator B',
            'email' => 'coordinator.b@uetmardan.edu.pk',
            'password' => bcrypt('password123'),
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2022->id,
            'status' => 'approved',
        ]);
        $this->coordinatorB->assignRole('Coordinator');
        $this->batch2022->update(['coordinator_id' => $this->coordinatorB->id]);

        // 7. Batch Adviser for 2021A
        $this->adviser = User::create([
            'name' => 'Adviser 2021',
            'email' => 'adviser2021@uetmardan.edu.pk',
            'password' => bcrypt('password123'),
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->section2021A->id,
            'status' => 'approved',
        ]);
        $this->adviser->assignRole('Batch Adviser');
        $this->adviser->assignedSections()->sync([$this->section2021A->id]);

        // 8. Students
        $this->student2021 = User::create([
            'name' => 'Student 2021',
            'email' => '21mdcs01@uetmardan.edu.pk',
            'password' => bcrypt('password'),
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->section2021A->id,
            'status' => 'approved',
        ]);
        $this->student2021->assignRole('Student');

        $student2022 = User::create([
            'name' => 'Student 2022',
            'email' => '22mdcs01@uetmardan.edu.pk',
            'password' => bcrypt('password'),
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2022->id,
            'section_id' => $this->section2022A->id,
            'status' => 'approved',
        ]);
        $student2022->assignRole('Student');

        // 9. Category & Complaints
        $this->category = ApplicationCategory::create([
            'name' => 'Academic Inquiry',
            'slug' => 'academic-inquiry',
            'description' => 'Academic inquiries',
            'is_active' => true,
        ]);

        $this->complaint2021 = Application::create([
            'ticket_number' => 'APP-2021-001',
            'title' => 'Issue in Batch 2021',
            'student_id' => $this->student2021->id,
            'category_id' => $this->category->id,
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->section2021A->id,
            'description' => 'Complaint for Batch 2021',
            'current_handler_role' => 'Coordinator',
            'status' => 'pending',
            'priority' => 'medium',
        ]);

        $this->complaint2022 = Application::create([
            'ticket_number' => 'APP-2022-001',
            'title' => 'Issue in Batch 2022',
            'student_id' => $student2022->id,
            'category_id' => $this->category->id,
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2022->id,
            'section_id' => $this->section2022A->id,
            'description' => 'Complaint for Batch 2022',
            'current_handler_role' => 'Coordinator',
            'status' => 'pending',
            'priority' => 'medium',
        ]);
    }

    /**
     * Scenario 1: Coordinator A can access their assigned batch.
     */
    public function test_01_coordinator_a_can_access_their_assigned_batch(): void
    {
        $this->assertEquals([$this->batch2021->id], $this->coordinatorA->getAssignedBatchIds());
        $this->assertTrue(Gate::forUser($this->coordinatorA)->allows('update', $this->batch2021));
    }

    /**
     * Scenario 2: Coordinator B cannot access Coordinator A's batch.
     */
    public function test_02_coordinator_b_cannot_access_coordinator_a_batch(): void
    {
        $this->assertFalse(in_array($this->batch2021->id, $this->coordinatorB->getAssignedBatchIds(), true));
        $this->assertFalse(Gate::forUser($this->coordinatorB)->allows('update', $this->batch2021));
    }

    /**
     * Scenario 3: Coordinator B cannot access another batch even if users.batch_id contains its ID.
     */
    public function test_03_coordinator_b_cannot_access_another_batch_via_stale_users_batch_id(): void
    {
        // Force stale users.batch_id on Coordinator B to point to Batch 2021
        $this->coordinatorB->update(['batch_id' => $this->batch2021->id]);
        $this->coordinatorB->refresh();

        // Authoritative source batches.coordinator_id still points exclusively to Batch 2022
        $assignedIds = $this->coordinatorB->getAssignedBatchIds();
        $this->assertNotContains($this->batch2021->id, $assignedIds);
        $this->assertContains($this->batch2022->id, $assignedIds);
        $this->assertFalse(Gate::forUser($this->coordinatorB)->allows('update', $this->batch2021));
    }

    /**
     * Scenario 4: Coordinator B cannot access another batch through assignedSections.
     */
    public function test_04_coordinator_b_cannot_access_another_batch_via_assigned_sections(): void
    {
        // Assign section 2021A to Coordinator B
        $this->coordinatorB->assignedSections()->sync([$this->section2021A->id]);
        $this->coordinatorB->refresh();

        $assignedIds = $this->coordinatorB->getAssignedBatchIds();
        $this->assertNotContains($this->batch2021->id, $assignedIds);
        $this->assertFalse(Gate::forUser($this->coordinatorB)->allows('update', $this->batch2021));
    }

    /**
     * Scenario 5: Coordinator B cannot view another batch's complaints.
     */
    public function test_05_coordinator_b_cannot_view_another_batch_complaints(): void
    {
        $repo = app(ApplicationRepository::class);
        $appsForB = $repo->getApplicationsForUser($this->coordinatorB);

        $this->assertFalse($appsForB->contains('id', $this->complaint2021->id));
        $this->assertTrue($appsForB->contains('id', $this->complaint2022->id));
        $this->assertFalse(Gate::forUser($this->coordinatorB)->allows('view', $this->complaint2021));
    }

    /**
     * Scenario 6: Coordinator B cannot update another batch's complaints.
     */
    public function test_06_coordinator_b_cannot_update_another_batch_complaints(): void
    {
        $this->assertFalse(Gate::forUser($this->coordinatorB)->allows('updateStatus', $this->complaint2021));
        $this->assertFalse(Gate::forUser($this->coordinatorB)->allows('addRemarks', $this->complaint2021));
    }

    /**
     * Scenario 7: Coordinator B cannot update or delete another batch's sections.
     */
    public function test_07_coordinator_b_cannot_update_or_delete_another_batch_sections(): void
    {
        $this->assertFalse(Gate::forUser($this->coordinatorB)->allows('update', $this->section2021A));
        $this->assertFalse(Gate::forUser($this->coordinatorB)->allows('delete', $this->section2021A));
    }

    /**
     * Scenario 8: Coordinator B cannot assign or remove advisers from another batch.
     */
    public function test_08_coordinator_b_cannot_assign_or_remove_advisers_from_another_batch(): void
    {
        $this->assertFalse(Gate::forUser($this->coordinatorB)->allows('assignAdviser', $this->section2021A));
        $this->assertFalse(Gate::forUser($this->coordinatorB)->allows('removeAdviser', $this->section2021A));
    }

    /**
     * Scenario 9: Coordinator cannot change batch assignment through profile updates.
     */
    public function test_09_coordinator_cannot_change_batch_via_profile_update(): void
    {
        $response = $this->actingAs($this->coordinatorB, 'sanctum')->putJson('/api/v1/auth/profile', [
            'name' => 'Prof. B Profile Update',
            'batch_id' => $this->batch2021->id, // Unauthorized attempt!
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['batch_id']);

        // Check normal profile update (without unauthorized batch) succeeds
        $validResponse = $this->actingAs($this->coordinatorB, 'sanctum')->putJson('/api/v1/auth/profile', [
            'name' => 'Prof. Coordinator B Legitimate',
            'phone' => '03001234567',
        ]);
        $validResponse->assertStatus(200);
        $this->assertEquals('Prof. Coordinator B Legitimate', $this->coordinatorB->fresh()->name);
    }

    /**
     * Scenario 10: Chairman can still manage Coordinator assignments.
     */
    public function test_10_chairman_can_still_manage_coordinator_assignments(): void
    {
        $userService = app(UserService::class);

        // Reassign Coordinator A from Batch 2021 to Batch 2023
        $updatedUser = $userService->updateStaff($this->coordinatorA, [
            'batch_id' => $this->batch2023->id,
        ]);

        $this->batch2021->refresh();
        $this->batch2023->refresh();

        $this->assertNull($this->batch2021->coordinator_id);
        $this->assertEquals($this->coordinatorA->id, $this->batch2023->coordinator_id);
        $this->assertEquals([$this->batch2023->id], $this->coordinatorA->fresh()->getAssignedBatchIds());
    }

    /**
     * Scenario 11: Batch Adviser workflows continue working.
     */
    public function test_11_batch_adviser_workflows_continue_working(): void
    {
        // Adviser resolves batches through users.batch_id and assignedSections
        $adviserBatchIds = $this->adviser->getAssignedBatchIds();
        $this->assertContains($this->batch2021->id, $adviserBatchIds);

        // Adviser can view section 2021A
        $this->assertTrue(Gate::forUser($this->adviser)->allows('view', $this->section2021A));
    }

    /**
     * Scenario 12: Student registration and approval workflows continue working.
     */
    public function test_12_student_registration_and_approval_continue_working(): void
    {
        $regResponse = $this->postJson('/api/v1/auth/register', [
            'name' => 'New Student 2021',
            'email' => '21mdcs77@uetmardan.edu.pk',
            'password' => 'secret123',
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->section2021A->id,
        ]);

        $regResponse->assertStatus(201);
        $studentId = $regResponse->json('data.user.id') ?? $regResponse->json('user.id');
        $student = User::findOrFail($studentId);

        $this->assertEquals('unlinked', $student->status);
        $this->assertEquals($this->batch2021->id, $student->batch_id);

        // Adviser approves
        $approveResponse = $this->actingAs($this->adviser, 'sanctum')->putJson("/api/v1/users/{$studentId}/status", [
            'status' => 'approved',
        ]);
        $approveResponse->assertStatus(200);
        $this->assertEquals('approved', $student->fresh()->status);
    }

    /**
     * Scenario 13: One batch cannot be assigned to two Coordinators.
     */
    public function test_13_one_batch_cannot_be_assigned_to_two_coordinators(): void
    {
        $userService = app(UserService::class);

        $this->expectException(\Illuminate\Validation\ValidationException::class);

        // Attempt to create Coordinator C on Batch 2021 (already held by Coordinator A)
        $userService->createStaff([
            'name' => 'Coordinator C Duplicate',
            'email' => 'coord.c@uetmardan.edu.pk',
            'password' => 'password123',
            'role' => 'Coordinator',
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
        ]);
    }

    /**
     * Scenario 14: One Coordinator can manage multiple batches if assigned.
     */
    public function test_14_one_coordinator_can_manage_multiple_batches(): void
    {
        $userService = app(UserService::class);

        // Assign Batch 2023 to Coordinator A in addition to Batch 2021
        $userService->updateStaff($this->coordinatorA, [
            'batch_id' => $this->batch2023->id,
            'keep_existing_batches' => true,
        ]);

        $this->batch2021->refresh();
        $this->batch2023->refresh();

        $this->assertEquals($this->coordinatorA->id, $this->batch2021->coordinator_id);
        $this->assertEquals($this->coordinatorA->id, $this->batch2023->coordinator_id);

        $assigned = $this->coordinatorA->fresh()->getAssignedBatchIds();
        $this->assertContains($this->batch2021->id, $assigned);
        $this->assertContains($this->batch2023->id, $assigned);
        $this->assertCount(2, $assigned);

        // Can access both batches
        $this->assertTrue(Gate::forUser($this->coordinatorA)->allows('view', $this->batch2021));
        $this->assertTrue(Gate::forUser($this->coordinatorA)->allows('view', $this->batch2023));
    }

    /**
     * Scenario 15: Deleting or changing a Coordinator's role correctly releases all their assigned batches.
     */
    public function test_15_deleting_or_changing_role_releases_all_assigned_batches(): void
    {
        $userService = app(UserService::class);

        // Change Coordinator B role to Office Staff
        $userService->updateStaff($this->coordinatorB, [
            'role' => 'Office Staff',
        ]);
        $this->batch2022->refresh();
        $this->assertNull($this->batch2022->coordinator_id);

        // Delete Coordinator A
        $userService->deleteStaff($this->coordinatorA);
        $this->batch2021->refresh();
        $this->assertNull($this->batch2021->coordinator_id);
    }
}
