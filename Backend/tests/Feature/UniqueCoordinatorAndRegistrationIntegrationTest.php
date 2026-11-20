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
use Illuminate\Support\Facades\DB;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class UniqueCoordinatorAndRegistrationIntegrationTest extends TestCase
{
    use RefreshDatabase;

    protected Department $department;
    protected Batch $batch2021;
    protected Batch $batch2022;
    protected Batch $batch2023;
    protected Section $section2021A;
    protected Section $section2021B;
    protected Section $section2022A;
    protected User $chairman;
    protected User $coordinatorA;
    protected User $adviser;
    protected ApplicationCategory $category;

    protected function setUp(): void
    {
        parent::setUp();

        // 1. Seed Roles
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
        $this->section2021B = Section::create([
            'batch_id' => $this->batch2021->id,
            'name' => 'B',
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

        // 6. Batch Adviser
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

        // 7. Category
        $this->category = ApplicationCategory::create([
            'name' => 'Academic Inquiry',
            'slug' => 'academic-inquiry',
            'description' => 'Academic inquiries and questions',
            'is_active' => true,
        ]);
    }

    /**
     * Test 1: Chairman can create a Coordinator and assign an available batch.
     */
    public function test_1_chairman_can_create_coordinator_and_assign_available_batch(): void
    {
        $response = $this->actingAs($this->chairman, 'sanctum')->postJson('/api/v1/users/staff', [
            'name' => 'Coordinator B',
            'email' => 'coord.b@uetmardan.edu.pk',
            'password' => 'secret123',
            'role' => 'Coordinator',
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2022->id,
        ]);

        $response->assertStatus(201);
        $this->batch2022->refresh();
        $this->assertNotNull($this->batch2022->coordinator_id);
        $this->assertEquals('Coordinator B', $this->batch2022->coordinator->name);
    }

    /**
     * Test 2: Chairman cannot assign an already assigned batch to another Coordinator.
     */
    public function test_2_chairman_cannot_assign_already_assigned_batch_to_another_coordinator(): void
    {
        // Batch 2021 is already assigned to coordinatorA
        $response = $this->actingAs($this->chairman, 'sanctum')->postJson('/api/v1/users/staff', [
            'name' => 'Coordinator C',
            'email' => 'coord.c@uetmardan.edu.pk',
            'password' => 'secret123',
            'role' => 'Coordinator',
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['batch_id']);
        $this->assertStringContainsString('already assigned', $response->json('errors.batch_id.0'));
    }

    /**
     * Test 3: The same Coordinator can retain their existing batch while editing their profile.
     */
    public function test_3_same_coordinator_can_retain_existing_batch_while_editing(): void
    {
        $response = $this->actingAs($this->chairman, 'sanctum')->putJson("/api/v1/users/staff/{$this->coordinatorA->id}", [
            'name' => 'Prof. Coordinator A Updated',
            'email' => 'coordinator.a@uetmardan.edu.pk',
            'batch_id' => $this->batch2021->id,
        ]);

        $response->assertStatus(200);
        $this->batch2021->refresh();
        $this->assertEquals($this->coordinatorA->id, $this->batch2021->coordinator_id);
    }

    /**
     * Test 4: A batch becomes available again only when its previous assignment is validly released.
     */
    public function test_4_batch_becomes_available_again_when_previous_assignment_is_released(): void
    {
        // Reassign Coordinator A from Batch 2021 to Batch 2023
        $updateResponse = $this->actingAs($this->chairman, 'sanctum')->putJson("/api/v1/users/staff/{$this->coordinatorA->id}", [
            'batch_id' => $this->batch2023->id,
        ]);
        $updateResponse->assertStatus(200);

        $this->batch2021->refresh();
        $this->batch2023->refresh();

        // Batch 2021 coordinator_id should now be NULL (released!)
        $this->assertNull($this->batch2021->coordinator_id);
        $this->assertEquals($this->coordinatorA->id, $this->batch2023->coordinator_id);

        // Now creating a new coordinator for Batch 2021 should succeed
        $createResponse = $this->actingAs($this->chairman, 'sanctum')->postJson('/api/v1/users/staff', [
            'name' => 'New Coordinator for 2021',
            'email' => 'new.coord2021@uetmardan.edu.pk',
            'password' => 'secret123',
            'role' => 'Coordinator',
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
        ]);

        $createResponse->assertStatus(201);
        $this->batch2021->refresh();
        $this->assertNotNull($this->batch2021->coordinator_id);
    }

    /**
     * Test 5: Two Coordinators cannot acquire the same batch.
     */
    public function test_5_two_coordinators_cannot_acquire_same_batch(): void
    {
        // Batch 2021 is held by coordinatorA
        // Attempting to assign Batch 2021 to another coordinator fails with 422
        $response = $this->actingAs($this->chairman, 'sanctum')->postJson('/api/v1/users/staff', [
            'name' => 'Concurrent Coordinator',
            'email' => 'concurrent@uetmardan.edu.pk',
            'password' => 'secret123',
            'role' => 'Coordinator',
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['batch_id']);
        $this->assertEquals($this->coordinatorA->id, $this->batch2021->fresh()->coordinator_id);
    }

    /**
     * Test 6: Registration API returns available batches and does not leak coordinator details to guests.
     */
    public function test_6_registration_api_returns_available_batches_without_leaking_staff_info(): void
    {
        $response = $this->getJson('/api/v1/batches');

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'success',
            'data' => [
                '*' => ['id', 'name', 'sections', 'start_year', 'end_year', 'is_active'],
            ],
        ]);

        // Unauthenticated guests must NOT receive coordinator_id or coordinator_name
        $firstItem = $response->json('data.0');
        $this->assertArrayNotHasKey('coordinator_id', $firstItem);
        $this->assertArrayNotHasKey('coordinator_name', $firstItem);
    }

    /**
     * Test 7: Student selecting Batch A receives only Batch A sections.
     */
    public function test_7_student_selecting_batch_receives_only_that_batch_sections(): void
    {
        $response = $this->getJson("/api/v1/sections?batch_id={$this->batch2021->id}");

        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertCount(2, $data);
        foreach ($data as $section) {
            $this->assertEquals($this->batch2021->id, $section['batch_id']);
        }
    }

    /**
     * Test 8: Changing the selected batch returns sections belonging exclusively to the new batch.
     */
    public function test_8_changing_selected_batch_queries_only_new_batch_sections(): void
    {
        $response2022 = $this->getJson("/api/v1/sections?batch_id={$this->batch2022->id}");

        $response2022->assertStatus(200);
        $data2022 = $response2022->json('data');
        $this->assertCount(1, $data2022);
        $this->assertEquals($this->batch2022->id, $data2022[0]['batch_id']);
        $this->assertEquals('A', $data2022[0]['name']);
    }

    /**
     * Test 9: Backend rejects registration when section belongs to another batch.
     */
    public function test_9_backend_rejects_section_belonging_to_another_batch(): void
    {
        // Batch 2022 selected, but section 2021A is submitted
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Mismatched Student',
            'email' => '21mdcs99@uetmardan.edu.pk',
            'password' => 'password123',
            'batch_id' => $this->batch2022->id,
            'section_id' => $this->section2021A->id, // Mismatch!
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['section_id']);
    }

    /**
     * Test 10: Backend rejects registration with invalid, non-existent, or inactive batch IDs.
     */
    public function test_10_backend_rejects_invalid_or_inactive_batch_ids(): void
    {
        // Non-existent batch
        $responseNonExistent = $this->postJson('/api/v1/auth/register', [
            'name' => 'Invalid Batch Student',
            'email' => '21mdcs98@uetmardan.edu.pk',
            'password' => 'password123',
            'batch_id' => 99999,
            'section_id' => $this->section2021A->id,
        ]);
        $responseNonExistent->assertStatus(422);

        // Inactive batch
        $inactiveBatch = Batch::create([
            'department_id' => $this->department->id,
            'name' => '2015-2019',
            'start_year' => 2015,
            'end_year' => 2019,
            'is_active' => false,
        ]);
        $inactiveSection = Section::create([
            'batch_id' => $inactiveBatch->id,
            'name' => 'A',
            'is_active' => true,
        ]);

        $responseInactive = $this->postJson('/api/v1/auth/register', [
            'name' => 'Inactive Batch Student',
            'email' => '15mdcs01@uetmardan.edu.pk',
            'password' => 'password123',
            'batch_id' => $inactiveBatch->id,
            'section_id' => $inactiveSection->id,
        ]);
        $responseInactive->assertStatus(422);
        $responseInactive->assertJsonValidationErrors(['batch_id']);
    }

    /**
     * Test 11: Existing student registration and adviser approval continue working.
     */
    public function test_11_existing_student_registration_and_adviser_approval_continue_working(): void
    {
        $regResponse = $this->postJson('/api/v1/auth/register', [
            'name' => 'Valid Student 2021',
            'email' => '21mdcs55@uetmardan.edu.pk',
            'password' => 'password123',
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->section2021A->id,
        ]);

        $regResponse->assertStatus(201);
        $studentId = $regResponse->json('data.user.id') ?? $regResponse->json('user.id');
        $this->assertNotNull($studentId);

        $student = User::find($studentId);
        $this->assertEquals('unlinked', $student->status);
        $this->assertEquals($this->batch2021->id, $student->batch_id);
        $this->assertEquals($this->section2021A->id, $student->section_id);

        // Batch Adviser approves the student
        $approveResponse = $this->actingAs($this->adviser, 'sanctum')->putJson("/api/v1/users/{$studentId}/status", [
            'status' => 'approved',
        ]);

        $approveResponse->assertStatus(200);
        $student->refresh();
        $this->assertEquals('approved', $student->status);
    }

    /**
     * Test 12: Existing Coordinator batch-level security remains intact.
     */
    public function test_12_coordinator_batch_level_security_remains_intact(): void
    {
        // Create Coordinator B for Batch 2022
        $coordinatorB = User::create([
            'name' => 'Prof. Coordinator B',
            'email' => 'coordinator.b@uetmardan.edu.pk',
            'password' => bcrypt('password123'),
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2022->id,
            'status' => 'approved',
        ]);
        $coordinatorB->assignRole('Coordinator');
        $this->batch2022->update(['coordinator_id' => $coordinatorB->id]);

        // Student from Batch 2021
        $student2021 = User::create([
            'name' => 'Student 2021',
            'email' => '21mdcs01@uetmardan.edu.pk',
            'password' => bcrypt('password'),
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->section2021A->id,
            'status' => 'approved',
        ]);
        $student2021->assignRole('Student');

        // Complaint submitted by Batch 2021 student
        $complaint2021 = Application::create([
            'ticket_number' => 'APP-2021-001',
            'title' => 'Issue in Batch 2021',
            'student_id' => $student2021->id,
            'category_id' => $this->category->id,
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->section2021A->id,
            'subject' => 'Issue in Batch 2021',
            'description' => 'Detailed complaint description',
            'current_handler_role' => 'Coordinator',
            'status' => 'pending',
            'priority' => 'medium',
        ]);

        // Coordinator B (Batch 2022) must NOT see Batch 2021 complaints
        $repo = app(ApplicationRepository::class);
        $applicationsForB = $repo->getApplicationsForUser($coordinatorB);
        $this->assertFalse($applicationsForB->contains('id', $complaint2021->id));

        // Coordinator A (Batch 2021) DOES see Batch 2021 complaints
        $applicationsForA = $repo->getApplicationsForUser($this->coordinatorA);
        $this->assertTrue($applicationsForA->contains('id', $complaint2021->id));
    }
}
