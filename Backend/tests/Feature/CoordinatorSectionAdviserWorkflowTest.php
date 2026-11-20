<?php

namespace Tests\Feature;

use App\Models\Batch;
use App\Models\Department;
use App\Models\Section;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class CoordinatorSectionAdviserWorkflowTest extends TestCase
{
    use RefreshDatabase;

    protected Department $department;
    protected Batch $batch2021;
    protected Batch $batch2022;
    protected Section $section2021A;
    protected Section $section2022A;
    protected User $chairman;
    protected User $coordinatorA;
    protected User $coordinatorB;

    protected function setUp(): void
    {
        parent::setUp();

        foreach (['Admin', 'Chairman', 'Coordinator', 'Batch Adviser', 'Batch Advisor', 'Student', 'Office Staff'] as $roleName) {
            Role::firstOrCreate(['name' => $roleName, 'guard_name' => 'web']);
            Role::firstOrCreate(['name' => $roleName, 'guard_name' => 'api']);
        }

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

        $this->chairman = User::factory()->create([
            'department_id' => $this->department->id,
            'email' => 'chairman@uetmardan.edu.pk',
        ]);
        $this->chairman->assignRole('Chairman');

        $this->coordinatorA = User::factory()->create([
            'department_id' => $this->department->id,
            'email' => 'coordinatorA@uetmardan.edu.pk',
        ]);
        $this->coordinatorA->assignRole('Coordinator');
        $this->batch2021->update(['coordinator_id' => $this->coordinatorA->id]);

        $this->coordinatorB = User::factory()->create([
            'department_id' => $this->department->id,
            'email' => 'coordinatorB@uetmardan.edu.pk',
        ]);
        $this->coordinatorB->assignRole('Coordinator');
        $this->batch2022->update(['coordinator_id' => $this->coordinatorB->id]);
    }

    public function test_01_chairman_creates_coordinator_using_starting_and_ending_years(): void
    {
        $response = $this->actingAs($this->chairman, 'sanctum')->postJson('/api/v1/users/staff', [
            'name' => 'New Coordinator 2023',
            'email' => 'coord2023@uetmardan.edu.pk',
            'password' => 'password123',
            'role' => 'Coordinator',
            'batch' => '2023-2027',
            'department_id' => $this->department->id,
        ]);

        $response->assertStatus(201);

        $createdUser = User::where('email', 'coord2023@uetmardan.edu.pk')->first();
        $this->assertNotNull($createdUser);
        $this->assertTrue($createdUser->hasRole('Coordinator'));

        $batch = Batch::where('name', '2023-2027')->first();
        $this->assertNotNull($batch);
        $this->assertEquals($createdUser->id, $batch->coordinator_id);
    }

    public function test_02_chairman_cannot_assign_already_assigned_batch_years(): void
    {
        // Batch 2021-2025 is already assigned to coordinatorA
        $response = $this->actingAs($this->chairman, 'sanctum')->postJson('/api/v1/users/staff', [
            'name' => 'Duplicate Coordinator',
            'email' => 'dupcoord@uetmardan.edu.pk',
            'password' => 'password123',
            'role' => 'Coordinator',
            'batch' => '2021-2025',
            'department_id' => $this->department->id,
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['batch_id']);
    }

    public function test_03_coordinator_creates_batch_adviser_for_selected_section_successfully(): void
    {
        // Coordinator A creates adviser for Section 2021A (belonging to Batch 2021)
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->postJson('/api/v1/users/staff', [
            'name' => 'Dr. Adviser 2021A',
            'email' => 'adviser2021a@uetmardan.edu.pk',
            'password' => 'password123',
            'role' => 'Batch Adviser',
            'batch' => '2021-2025',
            'batch_id' => $this->batch2021->id,
            'section' => 'A',
            'section_id' => $this->section2021A->id,
            'assigned_sections' => [
                [
                    'batch' => '2021-2025',
                    'batch_id' => $this->batch2021->id,
                    'section' => 'A',
                    'section_id' => $this->section2021A->id,
                ],
            ],
        ]);

        $response->assertStatus(201);

        $adviser = User::where('email', 'adviser2021a@uetmardan.edu.pk')->first();
        $this->assertNotNull($adviser);
        $this->assertTrue($adviser->hasRole('Batch Adviser'));
        $this->assertEquals($this->batch2021->id, $adviser->batch_id);
        $this->assertEquals($this->section2021A->id, $adviser->section_id);

        // Verify Section's assignedStaff contains the adviser
        $this->assertTrue(
            $this->section2021A->fresh()->assignedStaff->contains('id', $adviser->id)
        );
    }

    public function test_04_coordinator_cannot_create_or_assign_adviser_to_another_coordinators_batch(): void
    {
        // Coordinator A attempts to create an adviser for Coordinator B's batch (2022) and section
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->postJson('/api/v1/users/staff', [
            'name' => 'Cross Batch Adviser',
            'email' => 'crossadviser@uetmardan.edu.pk',
            'password' => 'password123',
            'role' => 'Batch Adviser',
            'batch' => '2022-2026',
            'batch_id' => $this->batch2022->id,
            'section' => 'A',
            'section_id' => $this->section2022A->id,
            'assigned_sections' => [
                [
                    'batch' => '2022-2026',
                    'batch_id' => $this->batch2022->id,
                    'section' => 'A',
                    'section_id' => $this->section2022A->id,
                ],
            ],
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['batch_id']);
    }

    public function test_05_coordinator_cannot_assign_adviser_to_another_coordinators_section_id(): void
    {
        // Coordinator A sends valid batch_id for 2021, but section_id belonging to 2022
        $response = $this->actingAs($this->coordinatorA, 'sanctum')->postJson('/api/v1/users/staff', [
            'name' => 'Mismatched Section Adviser',
            'email' => 'mismatchsec@uetmardan.edu.pk',
            'password' => 'password123',
            'role' => 'Batch Adviser',
            'batch' => '2021-2025',
            'batch_id' => $this->batch2021->id,
            'section' => 'A',
            'section_id' => $this->section2022A->id,
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['section_id']);
    }

    public function test_06_chairman_can_create_advisers_across_any_department_batch_and_section(): void
    {
        $response = $this->actingAs($this->chairman, 'sanctum')->postJson('/api/v1/users/staff', [
            'name' => 'Chairman Created Adviser',
            'email' => 'chairadviser@uetmardan.edu.pk',
            'password' => 'password123',
            'role' => 'Batch Adviser',
            'batch' => '2022-2026',
            'batch_id' => $this->batch2022->id,
            'section' => 'A',
            'section_id' => $this->section2022A->id,
            'department_id' => $this->department->id,
        ]);

        $response->assertStatus(201);
    }

    public function test_07_batch_adviser_page_data_retrieval_compatibility(): void
    {
        // 1. Create an adviser for Batch 2021 Section A
        $adviser = User::factory()->create([
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->section2021A->id,
            'email' => 'advtest@uetmardan.edu.pk',
        ]);
        $adviser->assignRole('Batch Adviser');
        $this->section2021A->assignedStaff()->sync([$adviser->id]);

        // 2. Adviser list query (used by Batch Adviser page)
        $response = $this->actingAs($this->chairman, 'sanctum')->getJson('/api/v1/users/staff?role=Batch+Adviser');
        $response->assertStatus(200);
        $response->assertJsonFragment(['email' => 'advtest@uetmardan.edu.pk']);

        // 3. Section query includes assignedStaff
        $secResponse = $this->actingAs($this->coordinatorA, 'sanctum')->getJson('/api/v1/sections');
        $secResponse->assertStatus(200);
        $secResponse->assertJsonFragment(['name' => 'A']);
    }
}

