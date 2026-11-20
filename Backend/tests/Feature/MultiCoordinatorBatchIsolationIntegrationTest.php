<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\ApplicationCategory;
use App\Models\Batch;
use App\Models\Department;
use App\Models\Section;
use App\Models\User;
use App\Repositories\ApplicationRepository;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class MultiCoordinatorBatchIsolationIntegrationTest extends TestCase
{
    use RefreshDatabase;

    protected Department $department;
    protected Batch $batch2021;
    protected Batch $batch2022;
    protected Section $section2021A;
    protected Section $section2022A;
    protected User $coordinatorA;
    protected User $coordinatorB;
    protected User $student2021;
    protected User $student2022;
    protected User $adviser2021;
    protected User $chairman;
    protected User $admin;
    protected ApplicationCategory $category;
    protected Application $complaint2021;
    protected Application $complaint2022;

    protected function setUp(): void
    {
        parent::setUp();

        // 1. Seed Roles
        foreach (['Admin', 'Chairman', 'Coordinator', 'Batch Adviser', 'Batch Advisor', 'Student', 'Office Staff', 'Dean', 'Vice Chancellor'] as $roleName) {
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

        // 4. Category
        $this->category = ApplicationCategory::create([
            'name' => 'Academic Inquiry',
            'slug' => 'academic-inquiry',
            'description' => 'Academic matters',
        ]);

        // 5. Users
        $this->admin = User::factory()->create([
            'department_id' => $this->department->id,
            'email' => 'admin@uetmardan.edu.pk',
        ]);
        $this->admin->assignRole('Admin');

        $this->chairman = User::factory()->create([
            'department_id' => $this->department->id,
            'email' => 'chairman.cs@uetmardan.edu.pk',
        ]);
        $this->chairman->assignRole('Chairman');

        // Coordinator A assigned to Batch 2021
        $this->coordinatorA = User::factory()->create([
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'email' => 'coord.2021@uetmardan.edu.pk',
        ]);
        $this->coordinatorA->assignRole('Coordinator');
        $this->batch2021->update(['coordinator_id' => $this->coordinatorA->id]);

        // Coordinator B assigned to Batch 2022
        $this->coordinatorB = User::factory()->create([
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2022->id,
            'email' => 'coord.2022@uetmardan.edu.pk',
        ]);
        $this->coordinatorB->assignRole('Coordinator');
        $this->batch2022->update(['coordinator_id' => $this->coordinatorB->id]);

        // Adviser for Batch 2021 Section A
        $this->adviser2021 = User::factory()->create([
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->section2021A->id,
            'email' => 'adviser.2021@uetmardan.edu.pk',
        ]);
        $this->adviser2021->assignRole('Batch Adviser');
        $this->adviser2021->assignedSections()->attach($this->section2021A->id);

        // Student in Batch 2021
        $this->student2021 = User::factory()->create([
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->section2021A->id,
            'adviser_id' => $this->adviser2021->id,
            'email' => 'student.2021@uetmardan.edu.pk',
        ]);
        $this->student2021->assignRole('Student');

        // Student in Batch 2022
        $this->student2022 = User::factory()->create([
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2022->id,
            'section_id' => $this->section2022A->id,
            'email' => 'student.2022@uetmardan.edu.pk',
        ]);
        $this->student2022->assignRole('Student');

        // Complaints
        $this->complaint2021 = Application::create([
            'department_id' => $this->department->id,
            'student_id' => $this->student2021->id,
            'assigned_to_id' => $this->adviser2021->id,
            'category_id' => $this->category->id,
            'title' => 'Batch 2021 Complaint',
            'description' => 'Course registration issue in Batch 2021',
            'status' => Application::STATUS_PENDING,
            'priority' => 'medium',
        ]);

        $this->complaint2022 = Application::create([
            'department_id' => $this->department->id,
            'student_id' => $this->student2022->id,
            'assigned_to_id' => null,
            'category_id' => $this->category->id,
            'title' => 'Batch 2022 Complaint',
            'description' => 'Fee challan discrepancy in Batch 2022',
            'status' => Application::STATUS_PENDING,
            'priority' => 'high',
        ]);
    }

    /**
     * Scenario 1: Coordinator A can see complaints from Batch 2021.
     */
    public function test_scenario_01_coordinator_a_can_see_complaints_from_batch_2021(): void
    {
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->getJson('/api/v1/applications');
        $response->assertStatus(200);

        $ids = collect($response->json('data'))->pluck('id')->map(fn($id) => (int)$id)->all();
        $this->assertContains($this->complaint2021->id, $ids);
    }

    /**
     * Scenario 2: Coordinator A cannot see complaints from Batch 2022.
     */
    public function test_scenario_02_coordinator_a_cannot_see_complaints_from_batch_2022(): void
    {
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->getJson('/api/v1/applications');
        $response->assertStatus(200);

        $ids = collect($response->json('data'))->pluck('id')->map(fn($id) => (int)$id)->all();
        $this->assertNotContains($this->complaint2022->id, $ids);
    }

    /**
     * Scenario 3: Coordinator B can see complaints from Batch 2022 and not Batch 2021.
     */
    public function test_scenario_03_coordinator_b_can_see_complaints_from_batch_2022_and_not_2021(): void
    {
        $response = $this->actingAs($this->coordinatorB, 'sanctum')->getJson('/api/v1/applications');
        $response->assertStatus(200);

        $ids = collect($response->json('data'))->pluck('id')->map(fn($id) => (int)$id)->all();
        $this->assertContains($this->complaint2022->id, $ids);
        $this->assertNotContains($this->complaint2021->id, $ids);
    }

    /**
     * Scenario 4: Coordinator A cannot view another batch's complaint by directly requesting its ID.
     */
    public function test_scenario_04_coordinator_a_cannot_view_another_batch_complaint_by_id(): void
    {
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->getJson("/api/v1/applications/{$this->complaint2022->id}");
        $response->assertStatus(403);
    }

    /**
     * Scenario 5: Coordinator A cannot resolve, reject, forward, or return another batch's complaint.
     */
    public function test_scenario_05_coordinator_a_cannot_modify_status_of_another_batch_complaint(): void
    {
        // Try forwarding
        $fwdResponse = $this->actingAs($this->coordinatorA, 'sanctum')->putJson("/api/v1/applications/{$this->complaint2022->id}/status", [
            'status' => 'forwarded',
            'assigned_to_id' => $this->chairman->id,
            'notes' => 'Attempting unauthorized cross-batch forwarding',
        ]);
        $fwdResponse->assertStatus(403);

        // Try resolving
        $resResponse = $this->actingAs($this->coordinatorA, 'sanctum')->putJson("/api/v1/applications/{$this->complaint2022->id}/status", [
            'status' => 'resolved',
            'notes' => 'Attempting unauthorized cross-batch resolution',
        ]);
        $resResponse->assertStatus(403);

        // Try rejecting
        $rejResponse = $this->actingAs($this->coordinatorA, 'sanctum')->putJson("/api/v1/applications/{$this->complaint2022->id}/status", [
            'status' => 'rejected',
            'notes' => 'Attempting unauthorized cross-batch rejection',
        ]);
        $rejResponse->assertStatus(403);
    }

    /**
     * Scenario 6: Direct assignment does not bypass the cross-batch authorization boundary.
     */
    public function test_scenario_06_direct_assignment_does_not_bypass_cross_batch_boundary(): void
    {
        // Force-assign Batch 2022 complaint directly to Coordinator A in DB
        $this->complaint2022->update(['assigned_to_id' => $this->coordinatorA->id]);

        // 1. Direct GET request by ID must still be denied (403)
        $viewResponse = $this->actingAs($this->coordinatorA, 'sanctum')->getJson("/api/v1/applications/{$this->complaint2022->id}");
        $viewResponse->assertStatus(403);

        // 2. Listing query must still exclude it
        $listResponse = $this->actingAs($this->coordinatorA, 'sanctum')->getJson('/api/v1/applications');
        $ids = collect($listResponse->json('data'))->pluck('id')->map(fn($id) => (int)$id)->all();
        $this->assertNotContains($this->complaint2022->id, $ids);

        // 3. Status mutation must still be denied (403)
        $mutResponse = $this->actingAs($this->coordinatorA, 'sanctum')->putJson("/api/v1/applications/{$this->complaint2022->id}/status", [
            'status' => 'resolved',
            'notes' => 'Attempting bypass via direct assignment',
        ]);
        $mutResponse->assertStatus(403);
    }

    /**
     * Scenario 7: Coordinator A can update and manage sections for Batch 2021.
     */
    public function test_scenario_07_coordinator_a_can_update_own_batch_sections(): void
    {
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->putJson("/api/v1/batches/{$this->batch2021->id}", [
            'sections' => ['A', 'B', 'C'],
        ]);
        $response->assertStatus(200);

        $sectionNames = $this->batch2021->fresh()->sections->pluck('name')->all();
        $this->assertContains('A', $sectionNames);
        $this->assertContains('B', $sectionNames);
        $this->assertContains('C', $sectionNames);
    }

    /**
     * Scenario 8: Coordinator A cannot update Batch 2022.
     */
    public function test_scenario_08_coordinator_a_cannot_update_another_batch(): void
    {
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->putJson("/api/v1/batches/{$this->batch2022->id}", [
            'sections' => ['X', 'Y'],
        ]);
        $response->assertStatus(403);
    }

    /**
     * Scenario 9: Coordinator A cannot delete Batch 2022.
     */
    public function test_scenario_09_coordinator_a_cannot_delete_another_batch(): void
    {
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->deleteJson("/api/v1/batches/{$this->batch2022->id}");
        $response->assertStatus(403);
    }

    /**
     * Scenario 10: Coordinator cannot delete a batch (even their own assigned batch).
     */
    public function test_scenario_10_coordinator_cannot_delete_own_batch(): void
    {
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->deleteJson("/api/v1/batches/{$this->batch2021->id}");
        $response->assertStatus(403);
        $this->assertNull($this->batch2021->fresh()->deleted_at);
    }

    /**
     * Scenario 11: Coordinator A can manage sections belonging to Batch 2021.
     */
    public function test_scenario_11_coordinator_a_can_update_sections_belonging_to_batch_2021(): void
    {
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->putJson("/api/v1/sections/{$this->section2021A->id}", [
            'name' => 'Section Alpha',
        ]);
        $response->assertStatus(200);
        $this->assertEquals('Section Alpha', $this->section2021A->fresh()->name);
    }

    /**
     * Scenario 12: Coordinator A cannot update sections belonging to Batch 2022.
     */
    public function test_scenario_12_coordinator_a_cannot_update_sections_belonging_to_batch_2022(): void
    {
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->putJson("/api/v1/sections/{$this->section2022A->id}", [
            'name' => 'Section Malicious',
        ]);
        $response->assertStatus(403);
    }

    /**
     * Scenario 13: Coordinator A cannot assign an adviser to another batch's section.
     */
    public function test_scenario_13_coordinator_a_cannot_assign_adviser_to_another_batch_section(): void
    {
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->postJson("/api/v1/sections/{$this->section2022A->id}/adviser", [
            'adviser_id' => $this->adviser2021->id,
        ]);
        $response->assertStatus(403);
    }

    /**
     * Scenario 14: Coordinator A cannot remove an adviser from another batch's section.
     */
    public function test_scenario_14_coordinator_a_cannot_remove_adviser_from_another_batch_section(): void
    {
        // First, assign adviser to Section 2022A via Admin
        $this->section2022A->assignedStaff()->attach($this->adviser2021->id);

        // Coordinator A tries to remove adviser from Section 2022A
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->deleteJson("/api/v1/sections/{$this->section2022A->id}/adviser/{$this->adviser2021->id}");
        $response->assertStatus(403);
    }

    /**
     * Scenario 15: Chairman and Admin retain their authorized functionality.
     */
    public function test_scenario_15_chairman_and_admin_retain_authorized_functionality(): void
    {
        // Chairman can view both complaints in the department
        $chairList = $this->actingAs($this->chairman, 'sanctum')->getJson('/api/v1/applications');
        $chairList->assertStatus(200);
        $ids = collect($chairList->json('data'))->pluck('id')->map(fn($id) => (int)$id)->all();
        $this->assertContains($this->complaint2021->id, $ids);
        $this->assertContains($this->complaint2022->id, $ids);

        // Admin can delete a batch
        $dummyBatch = Batch::create([
            'department_id' => $this->department->id,
            'name' => '2099-2103',
            'start_year' => 2099,
            'end_year' => 2103,
        ]);
        $delResponse = $this->actingAs($this->admin, 'sanctum')->deleteJson("/api/v1/batches/{$dummyBatch->id}");
        $delResponse->assertStatus(200);

        // Chairman can assign adviser to any section in department
        $assignResponse = $this->actingAs($this->chairman, 'sanctum')->postJson("/api/v1/sections/{$this->section2022A->id}/adviser", [
            'adviser_id' => $this->adviser2021->id,
        ]);
        $assignResponse->assertStatus(200);
    }

    /**
     * Scenario 16: Batch Adviser workflows continue working.
     */
    public function test_scenario_16_batch_adviser_workflows_continue_working(): void
    {
        // Batch Adviser can view complaint assigned to them or for their section's student
        $response = $this->actingAs($this->adviser2021, 'sanctum')->getJson("/api/v1/applications/{$this->complaint2021->id}");
        $response->assertStatus(200);

        // Batch Adviser can resolve complaint assigned to them
        $resResponse = $this->actingAs($this->adviser2021, 'sanctum')->putJson("/api/v1/applications/{$this->complaint2021->id}/status", [
            'status' => 'resolved',
            'notes' => 'Resolved by Batch Adviser',
        ]);
        $resResponse->assertStatus(200);
    }

    /**
     * Scenario 17: Student complaint submission continues working.
     */
    public function test_scenario_17_student_complaint_submission_continues_working(): void
    {
        $response = $this->actingAs($this->student2021, 'sanctum')->postJson('/api/v1/applications', [
            'title' => 'Lab Monitor Flickering',
            'description' => 'Monitor 4 in Lab 2 is flickering severely.',
            'category_id' => $this->category->id,
            'priority' => 'low',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('applications', [
            'title' => 'Lab Monitor Flickering',
            'student_id' => $this->student2021->id,
        ]);
    }

    /**
     * Scenario 18: Complaint history and timeline remain intact.
     */
    public function test_scenario_18_complaint_history_and_timeline_remain_intact(): void
    {
        // Coordinator A resolves complaint in their own batch
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->putJson("/api/v1/applications/{$this->complaint2021->id}/status", [
            'status' => 'resolved',
            'notes' => 'Resolution remarks by Coordinator A',
        ]);
        $response->assertStatus(200);

        // Verify remark created
        $this->assertDatabaseHas('application_remarks', [
            'application_id' => $this->complaint2021->id,
            'user_id' => $this->coordinatorA->id,
            'remark' => 'Resolution remarks by Coordinator A',
        ]);
    }

    /**
     * Scenario 19: Existing complaint pagination and filtering continue working.
     */
    public function test_scenario_19_complaint_pagination_and_filtering_continue_working(): void
    {
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->getJson('/api/v1/applications?search=registration');
        $response->assertStatus(200);
        $response->assertJsonStructure([
            'data',
            'meta' => ['pagination' => ['total', 'count', 'per_page', 'current_page', 'total_pages']],
        ]);

        $ids = collect($response->json('data'))->pluck('id')->map(fn($id) => (int)$id)->all();
        $this->assertContains($this->complaint2021->id, $ids);
    }

    /**
     * Scenario 20: Other roles' existing permissions are not unintentionally restricted.
     */
    public function test_scenario_20_other_roles_permissions_are_not_unintentionally_restricted(): void
    {
        // Student cannot view other students' complaints
        $response = $this->actingAs($this->student2021, 'sanctum')->getJson("/api/v1/applications/{$this->complaint2022->id}");
        $response->assertStatus(403);

        // Student can view their own complaint
        $ownResponse = $this->actingAs($this->student2021, 'sanctum')->getJson("/api/v1/applications/{$this->complaint2021->id}");
        $ownResponse->assertStatus(200);

        // Unassigned Coordinator (coordinator without a batch) sees 0 complaints (no accidental leak)
        $unassignedCoord = User::factory()->create([
            'department_id' => $this->department->id,
            'batch_id' => null,
            'email' => 'coord.unassigned@uetmardan.edu.pk',
        ]);
        $unassignedCoord->assignRole('Coordinator');

        $unassignedList = $this->actingAs($unassignedCoord, 'sanctum')->getJson('/api/v1/applications');
        $unassignedList->assertStatus(200);
        $this->assertEmpty($unassignedList->json('data'));
    }
}
