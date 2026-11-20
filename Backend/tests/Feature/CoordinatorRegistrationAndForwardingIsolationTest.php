<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\Batch;
use App\Models\Department;
use App\Models\Section;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class CoordinatorRegistrationAndForwardingIsolationTest extends TestCase
{
    use RefreshDatabase;

    protected Department $department;
    protected Batch $batch2021;
    protected Batch $batch2022;
    protected Batch $batch2023Unassigned;
    protected Section $section2021A;
    protected Section $section2021Inactive;
    protected Section $section2022A;
    protected User $coordinatorA;
    protected User $coordinatorB;
    protected User $adviserA;
    protected User $adviserOther;
    protected User $chairman;
    protected User $studentA;

    protected function setUp(): void
    {
        parent::setUp();

        foreach (['Admin', 'Chairman', 'Coordinator', 'Batch Adviser', 'Batch Advisor', 'Student', 'Office Staff'] as $roleName) {
            Role::firstOrCreate(['name' => $roleName, 'guard_name' => 'web']);
            Role::firstOrCreate(['name' => $roleName, 'guard_name' => 'api']);
        }

        $this->department = Department::create(['name' => 'Computer Science & IT', 'code' => 'CSIT']);

        // Coordinator A -> Batch 2021 (2021-2025)
        $this->coordinatorA = User::factory()->create([
            'name' => 'Coordinator Shams SB',
            'department_id' => $this->department->id,
            'email' => 'shams.coord@uetmardan.edu.pk',
        ]);
        $this->coordinatorA->assignRole('Coordinator');

        $this->batch2021 = Batch::create([
            'department_id' => $this->department->id,
            'coordinator_id' => $this->coordinatorA->id,
            'name' => 'Batch 2021-2025',
            'start_year' => 2021,
            'end_year' => 2025,
            'is_active' => true,
        ]);

        $this->section2021A = Section::create([
            'batch_id' => $this->batch2021->id,
            'name' => 'A',
            'is_active' => true,
        ]);

        $this->section2021Inactive = Section::create([
            'batch_id' => $this->batch2021->id,
            'name' => 'B_Inactive',
            'is_active' => false,
        ]);

        // Coordinator B -> Batch 2022 (2022-2026)
        $this->coordinatorB = User::factory()->create([
            'name' => 'Coordinator Talha SB',
            'department_id' => $this->department->id,
            'email' => 'talha.coord@uetmardan.edu.pk',
        ]);
        $this->coordinatorB->assignRole('Coordinator');

        $this->batch2022 = Batch::create([
            'department_id' => $this->department->id,
            'coordinator_id' => $this->coordinatorB->id,
            'name' => 'Batch 2022-2026',
            'start_year' => 2022,
            'end_year' => 2026,
            'is_active' => true,
        ]);

        $this->section2022A = Section::create([
            'batch_id' => $this->batch2022->id,
            'name' => 'A',
            'is_active' => true,
        ]);

        // Batch 2023: Active but NO assigned Coordinator
        $this->batch2023Unassigned = Batch::create([
            'department_id' => $this->department->id,
            'coordinator_id' => null,
            'name' => 'Batch 2023-2027',
            'start_year' => 2023,
            'end_year' => 2027,
            'is_active' => true,
        ]);

        // Chairman
        $this->chairman = User::factory()->create([
            'name' => 'Chairman CSIT',
            'department_id' => $this->department->id,
            'email' => 'chairman@uetmardan.edu.pk',
        ]);
        $this->chairman->assignRole('Chairman');

        // Batch Adviser A (assigned to Section 2021A)
        $this->adviserA = User::factory()->create([
            'name' => 'Adviser Zaheen SB',
            'department_id' => $this->department->id,
            'email' => 'zaheen.adviser@uetmardan.edu.pk',
            'section_id' => $this->section2021A->id,
            'batch_id' => $this->batch2021->id,
        ]);
        $this->adviserA->assignRole('Batch Adviser');
        $this->section2021A->assignedStaff()->attach($this->adviserA->id);

        // Batch Adviser Other (assigned to Section 2022A)
        $this->adviserOther = User::factory()->create([
            'name' => 'Adviser Other',
            'department_id' => $this->department->id,
            'email' => 'other.adviser@uetmardan.edu.pk',
            'section_id' => $this->section2022A->id,
            'batch_id' => $this->batch2022->id,
        ]);
        $this->adviserOther->assignRole('Batch Adviser');
        $this->section2022A->assignedStaff()->attach($this->adviserOther->id);

        // Student A in Batch 2021, Section A
        $this->studentA = User::factory()->create([
            'name' => 'Student Ali',
            'email' => 'ali.student@uetmardan.edu.pk',
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->section2021A->id,
            'adviser_id' => $this->adviserA->id,
        ]);
        $this->studentA->assignRole('Student');
    }

    public function test_01_registration_batches_endpoint_returns_only_active_batches_with_active_coordinators(): void
    {
        $response = $this->getJson('/api/v1/batches');

        $response->assertStatus(200)
            ->assertJsonPath('success', true);

        $returnedIds = collect($response->json('data'))->pluck('id')->map(fn($id) => (int)$id)->all();

        // Must include batches with active coordinator
        $this->assertContains($this->batch2021->id, $returnedIds);
        $this->assertContains($this->batch2022->id, $returnedIds);

        // Must NOT include batch without assigned coordinator
        $this->assertNotContains($this->batch2023Unassigned->id, $returnedIds);
    }

    public function test_02_registration_batches_endpoint_filters_out_inactive_sections(): void
    {
        $response = $this->getJson('/api/v1/batches');

        $response->assertStatus(200);

        $batch2021Data = collect($response->json('data'))->firstWhere('id', (string)$this->batch2021->id);
        $this->assertNotNull($batch2021Data);

        $sections = $batch2021Data['sections'] ?? [];
        $this->assertContains('A', $sections);
        $this->assertNotContains('B_Inactive', $sections);
    }

    public function test_03_student_registration_rejects_batch_without_active_coordinator(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'New Student',
            'email' => 'newstudent@uetmardan.edu.pk',
            'password' => 'Password123!',
            'batch_id' => $this->batch2023Unassigned->id,
            'section' => 'A',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['batch_id']);
    }

    public function test_04_student_registration_rejects_mismatched_section_and_batch(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'New Student 2',
            'email' => 'newstudent2@uetmardan.edu.pk',
            'password' => 'Password123!',
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->section2022A->id, // belongs to batch 2022
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['section_id']);
    }

    public function test_05_student_registration_succeeds_with_assigned_active_batch_and_matching_section(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Valid Student',
            'email' => 'validstudent@uetmardan.edu.pk',
            'password' => 'Password123!',
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->section2021A->id,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true);

        $created = User::where('email', 'validstudent@uetmardan.edu.pk')->first();
        $this->assertNotNull($created);
        $this->assertEquals($this->batch2021->id, $created->batch_id);
        $this->assertEquals($this->section2021A->id, $created->section_id);
    }

    public function test_06_batch_adviser_cannot_forward_complaint_to_coordinator_of_different_batch(): void
    {
        $complaint = Application::create([
            'department_id' => $this->department->id,
            'student_id' => $this->studentA->id,
            'assigned_to_id' => $this->adviserA->id,
            'title' => 'Grade Issue',
            'description' => 'Need re-evaluation',
            'status' => Application::STATUS_PENDING,
        ]);

        // Adviser A tries to forward to Coordinator B (who belongs to Batch 2022, not Batch 2021)
        $response = $this->actingAs($this->adviserA, 'sanctum')->putJson("/api/v1/complaints/{$complaint->id}/status", [
            'status' => 'forwarded',
            'assigned_to_id' => $this->coordinatorB->id,
            'notes' => 'Forwarding to coordinator B by mistake',
        ]);

        $response->assertStatus(422)
            ->assertJsonPath('message', 'Complaints can only be forwarded to the Coordinator assigned to this batch.');
    }

    public function test_07_batch_adviser_cannot_forward_complaint_when_batch_has_no_coordinator(): void
    {
        // Unassign coordinator from Batch 2021
        $this->batch2021->update(['coordinator_id' => null]);

        $complaint = Application::create([
            'department_id' => $this->department->id,
            'student_id' => $this->studentA->id,
            'assigned_to_id' => $this->adviserA->id,
            'title' => 'Course Registration',
            'description' => 'Cannot register',
            'status' => Application::STATUS_PENDING,
        ]);

        $response = $this->actingAs($this->adviserA, 'sanctum')->putJson("/api/v1/complaints/{$complaint->id}/status", [
            'status' => 'forwarded',
            'assigned_to_id' => $this->coordinatorA->id,
            'notes' => 'Forwarding to coordinator',
        ]);

        $response->assertStatus(422)
            ->assertJsonPath('message', 'No Coordinator is currently assigned to this batch.');
    }

    public function test_08_batch_adviser_can_forward_complaint_to_assigned_coordinator_of_own_batch(): void
    {
        $complaint = Application::create([
            'department_id' => $this->department->id,
            'student_id' => $this->studentA->id,
            'assigned_to_id' => $this->adviserA->id,
            'title' => 'Exam Retake',
            'description' => 'Medical certificate attached',
            'status' => Application::STATUS_PENDING,
        ]);

        $response = $this->actingAs($this->adviserA, 'sanctum')->putJson("/api/v1/complaints/{$complaint->id}/status", [
            'status' => 'forwarded',
            'assigned_to_id' => $this->coordinatorA->id,
            'notes' => 'Forwarded to batch coordinator Shams SB for review',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'forwarded')
            ->assertJsonPath('data.assigned_to_id', (string)$this->coordinatorA->id);

        $complaint->refresh();
        $this->assertEquals(Application::STATUS_FORWARDED, $complaint->status);
        $this->assertEquals($this->coordinatorA->id, $complaint->assigned_to_id);
    }

    public function test_09_batch_adviser_cannot_forward_complaint_of_unauthorized_section(): void
    {
        // Complaint belongs to Student A (Section 2021A)
        $complaint = Application::create([
            'department_id' => $this->department->id,
            'student_id' => $this->studentA->id,
            'assigned_to_id' => $this->adviserOther->id, // Assigned to other adviser but student is not in other adviser's section
            'title' => 'Section Clash',
            'description' => 'Class clash',
            'status' => Application::STATUS_PENDING,
        ]);

        // AdviserOther tries to forward but has no relation to Section 2021A
        $response = $this->actingAs($this->adviserOther, 'sanctum')->putJson("/api/v1/complaints/{$complaint->id}/status", [
            'status' => 'forwarded',
            'assigned_to_id' => $this->coordinatorA->id,
            'notes' => 'Attempting forward',
        ]);

        $response->assertStatus(403);
    }

    public function test_10_forward_recipients_endpoint_returns_only_assigned_coordinator(): void
    {
        $complaint = Application::create([
            'department_id' => $this->department->id,
            'student_id' => $this->studentA->id,
            'assigned_to_id' => $this->adviserA->id,
            'title' => 'Fee Issue',
            'description' => 'Challan missing',
            'status' => Application::STATUS_PENDING,
        ]);

        $response = $this->actingAs($this->adviserA, 'sanctum')->getJson("/api/v1/complaints/{$complaint->id}/recipients");

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.has_assigned_coordinator', true)
            ->assertJsonPath('data.assigned_coordinator.id', (string)$this->coordinatorA->id);

        $recipientIds = collect($response->json('data.recipients'))->pluck('id')->all();
        $this->assertContains((string)$this->coordinatorA->id, $recipientIds);
        $this->assertNotContains((string)$this->coordinatorB->id, $recipientIds);
    }
}
