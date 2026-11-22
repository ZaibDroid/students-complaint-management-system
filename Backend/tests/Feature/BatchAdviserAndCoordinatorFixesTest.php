<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\ApplicationCategory;
use App\Models\Batch;
use App\Models\Department;
use App\Models\Section;
use App\Models\User;
use App\Repositories\ApplicationRepository;
use App\Repositories\DashboardRepository;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Gate;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class BatchAdviserAndCoordinatorFixesTest extends TestCase
{
    use RefreshDatabase;

    protected Department $department;
    protected Batch $batch2021;
    protected Batch $batch2022;
    protected Section $sectionAI;
    protected Section $sectionCS;
    protected Section $sectionDS;
    protected Section $section2022A;
    protected User $chairman;
    protected User $coordinatorA;
    protected User $coordinatorB;
    protected User $coordinatorUnassigned;
    protected User $adviserAI;
    protected User $adviserCS;
    protected ApplicationCategory $category;

    protected function setUp(): void
    {
        parent::setUp();

        // 1. Setup Roles
        foreach (['Admin', 'Chairman', 'Coordinator', 'Batch Adviser', 'Batch Advisor', 'Student', 'Office Staff'] as $roleName) {
            Role::firstOrCreate(['name' => $roleName, 'guard_name' => 'web']);
            Role::firstOrCreate(['name' => $roleName, 'guard_name' => 'api']);
        }

        // 2. Department
        $this->department = Department::create([
            'name' => 'Computer Science & IT',
            'code' => 'CSIT',
        ]);

        // 3. Batches
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

        // 4. Sections for Batch 2021 (AI, CS, DS)
        $this->sectionAI = Section::create([
            'batch_id' => $this->batch2021->id,
            'name' => 'AI',
            'is_active' => true,
        ]);

        $this->sectionCS = Section::create([
            'batch_id' => $this->batch2021->id,
            'name' => 'CS',
            'is_active' => true,
        ]);

        $this->sectionDS = Section::create([
            'batch_id' => $this->batch2021->id,
            'name' => 'DS',
            'is_active' => true,
        ]);

        $this->section2022A = Section::create([
            'batch_id' => $this->batch2022->id,
            'name' => 'A',
            'is_active' => true,
        ]);

        // 5. Chairman
        $this->chairman = User::factory()->create([
            'name' => 'Chairman CSIT',
            'email' => 'chairman@uetmardan.edu.pk',
            'department_id' => $this->department->id,
            'status' => 'approved',
        ]);
        $this->chairman->assignRole('Chairman');

        // 6. Coordinator A -> Batch 2021
        $this->coordinatorA = User::factory()->create([
            'name' => 'Coordinator Shams SB',
            'email' => 'coordinator.a@uetmardan.edu.pk',
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'status' => 'approved',
        ]);
        $this->coordinatorA->assignRole('Coordinator');
        $this->batch2021->update(['coordinator_id' => $this->coordinatorA->id]);

        // 7. Coordinator B -> Batch 2022
        $this->coordinatorB = User::factory()->create([
            'name' => 'Coordinator Talha SB',
            'email' => 'coordinator.b@uetmardan.edu.pk',
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2022->id,
            'status' => 'approved',
        ]);
        $this->coordinatorB->assignRole('Coordinator');
        $this->batch2022->update(['coordinator_id' => $this->coordinatorB->id]);

        // 8. Coordinator without assigned batch
        $this->coordinatorUnassigned = User::factory()->create([
            'name' => 'Coordinator Unassigned',
            'email' => 'coordinator.unassigned@uetmardan.edu.pk',
            'department_id' => $this->department->id,
            'batch_id' => null,
            'status' => 'approved',
        ]);
        $this->coordinatorUnassigned->assignRole('Coordinator');

        // 9. Advisers for Batch 2021
        $this->adviserAI = User::factory()->create([
            'name' => 'Adviser AI',
            'email' => 'adviser.ai@uetmardan.edu.pk',
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->sectionAI->id,
            'status' => 'approved',
        ]);
        $this->adviserAI->assignRole('Batch Adviser');
        $this->sectionAI->assignedStaff()->attach($this->adviserAI->id);

        $this->adviserCS = User::factory()->create([
            'name' => 'Adviser CS',
            'email' => 'adviser.cs@uetmardan.edu.pk',
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->sectionCS->id,
            'status' => 'approved',
        ]);
        $this->adviserCS->assignRole('Batch Adviser');
        $this->sectionCS->assignedStaff()->attach($this->adviserCS->id);

        // 10. Category
        $this->category = ApplicationCategory::create([
            'name' => 'Academic Inquiry',
            'slug' => 'academic-inquiry',
            'description' => 'Academic inquiries',
            'is_active' => true,
        ]);
    }

    /**
     * Test 1: Automatically Assign the Coordinator's Batch When Creating a Batch Adviser.
     * Coordinator creates adviser without passing batch_id; backend automatically assigns coordinator's batch.
     * If coordinator has no assigned batch, creation is rejected with 422.
     */
    public function test_01_coordinator_creates_batch_adviser_with_automatic_batch_assignment(): void
    {
        // 1. Coordinator A creates a new adviser for Section DS without passing batch_id
        $response = $this->actingAs($this->coordinatorA, 'sanctum')
            ->postJson('/api/v1/users/staff', [
                'name' => 'Adviser DS',
                'email' => 'adviser.ds@uetmardan.edu.pk',
                'password' => 'Password123!',
                'role' => 'Batch Adviser',
                'section_id' => $this->sectionDS->id,
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true);

        // Verify adviser in DB is automatically assigned to Coordinator A's batch (Batch 2021)
        $createdAdviser = User::where('email', 'adviser.ds@uetmardan.edu.pk')->first();
        $this->assertNotNull($createdAdviser);
        $this->assertEquals($this->batch2021->id, $createdAdviser->batch_id);
        $this->assertEquals($this->department->id, $createdAdviser->department_id);
        $this->assertEquals($this->sectionDS->id, $createdAdviser->section_id);

        // 2. Coordinator Unassigned (no batch) attempts to create adviser -> rejected with 422
        $responseUnassigned = $this->actingAs($this->coordinatorUnassigned, 'sanctum')
            ->postJson('/api/v1/users/staff', [
                'name' => 'Adviser Fail',
                'email' => 'adviser.fail@uetmardan.edu.pk',
                'password' => 'Password123!',
                'role' => 'Batch Adviser',
                'section_id' => $this->sectionDS->id,
            ]);

        $responseUnassigned->assertStatus(422)
            ->assertJsonValidationErrors(['batch_id']);

        // 3. Coordinator cannot assign an adviser to another coordinator's batch
        $responseCross = $this->actingAs($this->coordinatorA, 'sanctum')
            ->postJson('/api/v1/users/staff', [
                'name' => 'Adviser Cross',
                'email' => 'adviser.cross@uetmardan.edu.pk',
                'password' => 'Password123!',
                'role' => 'Batch Adviser',
                'batch_id' => $this->batch2022->id,
                'section_id' => $this->section2022A->id,
            ]);

        $responseCross->assertStatus(422)
            ->assertJsonValidationErrors(['batch_id']);
    }

    /**
     * Test 2: Student Must Be Able to Log In After Adviser Rejects or Cancels a Linking Request.
     * Student account remains active and usable. Student can log in, edit profile, and re-link.
     */
    public function test_02_student_can_login_update_profile_and_relink_after_adviser_rejection(): void
    {
        // 1. Create student initially with linking to Adviser AI
        $student = User::create([
            'name' => 'Student Tariq',
            'email' => 'tariq.student@uetmardan.edu.pk',
            'password' => bcrypt('Password123!'),
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->sectionAI->id,
            'adviser_id' => $this->adviserAI->id,
            'status' => 'pending',
        ]);
        $student->assignRole('Student');

        // 2. Adviser rejects or cancels linking request
        $responseReject = $this->actingAs($this->adviserAI, 'sanctum')
            ->putJson("/api/v1/users/{$student->id}/status", [
                'status' => 'rejected',
            ]);
        $responseReject->assertStatus(200);

        $student->refresh();
        $this->assertEquals('rejected', $student->status);
        $this->assertNull($student->adviser_id);

        // 3. Student logs in despite status being 'rejected'
        $loginResponse = $this->postJson('/api/v1/auth/login', [
            'email' => 'tariq.student@uetmardan.edu.pk',
            'password' => 'Password123!',
        ]);

        $loginResponse->assertStatus(200)
            ->assertJsonPath('success', true);
        $this->assertNotEmpty($loginResponse->json('data.token'));
        $this->assertEquals('rejected', $loginResponse->json('data.user.status'));

        // 4. Student can update profile information (e.g. phone)
        $profileResponse = $this->actingAs($student, 'sanctum')
            ->putJson('/api/v1/auth/profile', [
                'phone' => '03001234567',
                'name' => 'Student Tariq Updated',
            ]);

        $profileResponse->assertStatus(200);
        $student->refresh();
        $this->assertEquals('03001234567', $student->phone);
        $this->assertEquals('Student Tariq Updated', $student->name);

        // 5. Student re-submits linking request to Adviser CS
        $relinkResponse = $this->actingAs($student, 'sanctum')
            ->putJson("/api/v1/users/{$student->id}/adviser", [
                'adviser_id' => (string)$this->adviserCS->id,
            ]);

        $relinkResponse->assertStatus(200);
        $student->refresh();
        $this->assertEquals($this->adviserCS->id, $student->adviser_id);
        $this->assertEquals('pending', $student->status);

        // 6. Adviser CS approves the student
        $approveResponse = $this->actingAs($this->adviserCS, 'sanctum')
            ->putJson("/api/v1/users/{$student->id}/status", [
                'status' => 'approved',
            ]);
        $approveResponse->assertStatus(200);
        $student->refresh();
        $this->assertEquals('approved', $student->status);
    }

    /**
     * Test 3: Section Mapping preserves multi-character section names (AI, CS, DS) and never truncates to 'A'.
     */
    public function test_03_section_mapping_preserves_multi_character_section_names(): void
    {
        // 1. Register student in section AI
        $registerResponse = $this->postJson('/api/v1/auth/register', [
            'name' => 'AI Student',
            'email' => 'ai.student@uetmardan.edu.pk',
            'password' => 'Password123!',
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->sectionAI->id,
            'section' => 'AI',
        ]);

        $registerResponse->assertStatus(201)
            ->assertJsonPath('success', true);

        $student = User::where('email', 'ai.student@uetmardan.edu.pk')->first();
        $this->assertNotNull($student);
        $this->assertEquals('AI', $student->section?->name);
        $this->assertEquals($this->sectionAI->id, $student->section_id);

        // 2. Fetch profile via /api/v1/auth/me
        $profileResponse = $this->actingAs($student, 'sanctum')->getJson('/api/v1/auth/me');
        $profileResponse->assertStatus(200);
        $resSection = $profileResponse->json('data.section') ?? $profileResponse->json('data.user.section');
        $this->assertEquals('AI', $resSection);

        // 3. Update profile selecting section CS
        $updateResponse = $this->actingAs($student, 'sanctum')->putJson('/api/v1/auth/profile', [
            'section_id' => $this->sectionCS->id,
            'section' => 'CS',
        ]);

        $updateResponse->assertStatus(200);
        $student->refresh();
        $this->assertEquals('CS', $student->section?->name);
        $this->assertEquals($this->sectionCS->id, $student->section_id);
        $this->assertNotEquals('A', $student->section?->name);
    }

    /**
     * Test 4: Direct Adviser-to-Chairman forwarding visibility:
     * Complaint forwarded directly from Adviser to Chairman is visible to Chairman,
     * but strictly hidden from Coordinator (in complaint list, dashboard, and direct API access).
     */
    public function test_04_direct_adviser_to_chairman_forwarding_hidden_from_coordinator(): void
    {
        // 1. Student registers and submits complaint
        $student = User::create([
            'name' => 'Student Complaint Author',
            'email' => 'author@uetmardan.edu.pk',
            'password' => bcrypt('password'),
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->sectionAI->id,
            'adviser_id' => $this->adviserAI->id,
            'status' => 'approved',
        ]);
        $student->assignRole('Student');

        $complaint = Application::create([
            'ticket_number' => 'APP-2021-DIR01',
            'title' => 'Urgent Issue for Chairman',
            'student_id' => $student->id,
            'category_id' => $this->category->id,
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->sectionAI->id,
            'subject' => 'Urgent Issue for Chairman',
            'description' => 'This needs immediate Chairman attention.',
            'assigned_to_id' => $this->adviserAI->id,
            'current_handler_role' => 'Batch Adviser',
            'status' => 'pending',
            'priority' => 'high',
        ]);

        // 2. Adviser forwards directly to Chairman
        $forwardResponse = $this->actingAs($this->adviserAI, 'sanctum')
            ->putJson("/api/v1/applications/{$complaint->id}/status", [
                'status' => 'forwarded',
                'assigned_to_id' => $this->chairman->id,
                'notes' => 'Direct escalation to Chairman.',
            ]);

        $forwardResponse->assertStatus(200);
        $complaint->refresh();
        $this->assertEquals($this->chairman->id, $complaint->assigned_to_id);

        // 3. Chairman CAN view complaint
        $chairmanViewResponse = $this->actingAs($this->chairman, 'sanctum')
            ->getJson("/api/v1/applications/{$complaint->id}");
        $chairmanViewResponse->assertStatus(200);

        // 4. Coordinator A CANNOT view complaint via direct API call (403 Forbidden)
        $coordViewResponse = $this->actingAs($this->coordinatorA, 'sanctum')
            ->getJson("/api/v1/applications/{$complaint->id}");
        $coordViewResponse->assertStatus(403);
        $this->assertFalse(Gate::forUser($this->coordinatorA)->allows('view', $complaint));

        // 5. Coordinator A query/list does NOT contain this complaint
        $repo = app(ApplicationRepository::class);
        $coordList = $repo->getApplicationsForUser($this->coordinatorA);
        $this->assertFalse($coordList->contains('id', $complaint->id));

        // 6. Coordinator A dashboard metrics do NOT count this complaint
        $dashRepo = app(DashboardRepository::class);
        $dashMetrics = $dashRepo->getCoordinatorDashboard($this->coordinatorA);
        $pending = $dashMetrics['metrics']['pending_forwarding'] ?? $dashMetrics['pending_forwarding'] ?? 0;
        $this->assertEquals(0, $pending);
        $this->assertFalse(collect($dashMetrics['recent_activity'])->contains('id', $complaint->id));
    }

    /**
     * Test 5: Adviser-to-Coordinator forwarding visibility:
     * When Adviser forwards to Coordinator A, Coordinator A CAN see it in list, dashboard, and details.
     * Unrelated Coordinator B (Batch 2022) CANNOT see it.
     */
    public function test_05_adviser_to_coordinator_forwarding_visible_only_to_assigned_coordinator(): void
    {
        // 1. Student in Batch 2021
        $student = User::create([
            'name' => 'Student Batch 2021',
            'email' => 'student.b21@uetmardan.edu.pk',
            'password' => bcrypt('password'),
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->sectionAI->id,
            'adviser_id' => $this->adviserAI->id,
            'status' => 'approved',
        ]);
        $student->assignRole('Student');

        $complaint = Application::create([
            'ticket_number' => 'APP-2021-COORD01',
            'title' => 'Issue for Coordinator',
            'student_id' => $student->id,
            'category_id' => $this->category->id,
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->sectionAI->id,
            'subject' => 'Issue for Coordinator',
            'description' => 'Batch issue requires coordinator review.',
            'assigned_to_id' => $this->adviserAI->id,
            'current_handler_role' => 'Batch Adviser',
            'status' => 'pending',
            'priority' => 'medium',
        ]);

        // 2. Adviser forwards complaint to Coordinator A
        $forwardResponse = $this->actingAs($this->adviserAI, 'sanctum')
            ->putJson("/api/v1/applications/{$complaint->id}/status", [
                'status' => 'forwarded',
                'assigned_to_id' => $this->coordinatorA->id,
                'notes' => 'Forwarding to Batch 2021 Coordinator.',
            ]);

        $forwardResponse->assertStatus(200);
        $complaint->refresh();
        $this->assertEquals($this->coordinatorA->id, $complaint->assigned_to_id);

        // 3. Coordinator A CAN view complaint via direct API call (200 OK)
        $coordAView = $this->actingAs($this->coordinatorA, 'sanctum')
            ->getJson("/api/v1/applications/{$complaint->id}");
        $coordAView->assertStatus(200);
        $this->assertTrue(Gate::forUser($this->coordinatorA)->allows('view', $complaint));

        // 4. Coordinator A list query CONTAINS this complaint
        $repo = app(ApplicationRepository::class);
        $coordAList = $repo->getApplicationsForUser($this->coordinatorA);
        $this->assertTrue($coordAList->contains('id', $complaint->id));

        // 5. Coordinator A dashboard includes this complaint
        $dashRepo = app(DashboardRepository::class);
        $dashA = $dashRepo->getCoordinatorDashboard($this->coordinatorA);
        $pendingA = $dashA['metrics']['pending_forwarding'] ?? $dashA['pending_forwarding'] ?? 0;
        $this->assertGreaterThan(0, $pendingA);

        // 6. Coordinator B (Batch 2022) CANNOT view complaint (403 Forbidden)
        $coordBView = $this->actingAs($this->coordinatorB, 'sanctum')
            ->getJson("/api/v1/applications/{$complaint->id}");
        $coordBView->assertStatus(403);
        $this->assertFalse(Gate::forUser($this->coordinatorB)->allows('view', $complaint));

        // 7. Coordinator B list query does NOT contain this complaint
        $coordBList = $repo->getApplicationsForUser($this->coordinatorB);
        $this->assertFalse($coordBList->contains('id', $complaint->id));
    }

    /**
     * Test 6: Scenario C: Coordinator forwards complaint to Chairman.
     * Previous Coordinator loses access once forwarded away to Chairman.
     * Historical involvement in timeline (from_user_id) does not grant permanent access.
     */
    public function test_06_coordinator_forwards_complaint_to_chairman_and_loses_access(): void
    {
        // 1. Complaint assigned to Coordinator A
        $student = User::create([
            'name' => 'Student Batch 2021 Escalation',
            'email' => 'student.esc@uetmardan.edu.pk',
            'password' => bcrypt('password'),
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->sectionAI->id,
            'adviser_id' => $this->adviserAI->id,
            'status' => 'approved',
        ]);
        $student->assignRole('Student');

        $complaint = Application::create([
            'ticket_number' => 'APP-2021-FWD01',
            'title' => 'Complex Issue for Chairman',
            'student_id' => $student->id,
            'category_id' => $this->category->id,
            'department_id' => $this->department->id,
            'batch_id' => $this->batch2021->id,
            'section_id' => $this->sectionAI->id,
            'subject' => 'Complex Issue for Chairman',
            'description' => 'Needs Chairman ruling.',
            'assigned_to_id' => $this->coordinatorA->id,
            'current_handler_role' => 'Coordinator',
            'status' => 'pending',
            'priority' => 'high',
        ]);

        // Coordinator A initially CAN view complaint
        $this->assertTrue(Gate::forUser($this->coordinatorA)->allows('view', $complaint));
        $coordAInitView = $this->actingAs($this->coordinatorA, 'sanctum')->getJson("/api/v1/applications/{$complaint->id}");
        $coordAInitView->assertStatus(200);

        // 2. Coordinator A forwards complaint to Chairman
        $forwardResponse = $this->actingAs($this->coordinatorA, 'sanctum')
            ->putJson("/api/v1/applications/{$complaint->id}/status", [
                'status' => 'forwarded',
                'assigned_to_id' => $this->chairman->id,
                'notes' => 'Escalating to Chairman for decision.',
            ]);

        $forwardResponse->assertStatus(200);
        $complaint->refresh();
        $this->assertEquals($this->chairman->id, $complaint->assigned_to_id);

        // 3. Chairman CAN view complaint
        $this->assertTrue(Gate::forUser($this->chairman)->allows('view', $complaint));
        $chairView = $this->actingAs($this->chairman, 'sanctum')->getJson("/api/v1/applications/{$complaint->id}");
        $chairView->assertStatus(200);

        // 4. Coordinator A (who forwarded it) LOSES access:
        // Direct API call is rejected with 403 Forbidden
        $coordAAfterView = $this->actingAs($this->coordinatorA, 'sanctum')->getJson("/api/v1/applications/{$complaint->id}");
        $coordAAfterView->assertStatus(403);
        $this->assertFalse(Gate::forUser($this->coordinatorA)->allows('view', $complaint));

        // Coordinator A complaint list excludes this complaint
        $repo = app(ApplicationRepository::class);
        $coordAList = $repo->getApplicationsForUser($this->coordinatorA);
        $this->assertFalse($coordAList->contains('id', $complaint->id));

        // Coordinator A dashboard does NOT count this complaint in pending_forwarding
        $dashRepo = app(DashboardRepository::class);
        $dashA = $dashRepo->getCoordinatorDashboard($this->coordinatorA);
        $pendingA = $dashA['metrics']['pending_forwarding'] ?? $dashA['pending_forwarding'] ?? 0;
        $this->assertEquals(0, $pendingA);
        $this->assertFalse(collect($dashA['recent_activity'])->contains('id', $complaint->id));
    }

    /**
     * Test 7: Coordinator with multiple batches assigns the correct batch from section without arbitrary assignment.
     */
    public function test_07_coordinator_with_multiple_batches_assigns_correct_batch_from_section(): void
    {
        // Assign a second batch (Batch 2023) to Coordinator A
        $batch2023 = Batch::create([
            'department_id' => $this->department->id,
            'coordinator_id' => $this->coordinatorA->id,
            'name' => '2023-2027',
            'start_year' => 2023,
            'end_year' => 2027,
            'is_active' => true,
        ]);

        $section2023A = Section::create([
            'batch_id' => $batch2023->id,
            'name' => 'SE-A',
            'is_active' => true,
        ]);

        // Coordinator A creates adviser for Section 2023A without specifying batch_id
        $response = $this->actingAs($this->coordinatorA, 'sanctum')
            ->postJson('/api/v1/users/staff', [
                'name' => 'Adviser SE-A',
                'email' => 'adviser.sea@uetmardan.edu.pk',
                'password' => 'Password123!',
                'role' => 'Batch Adviser',
                'section_id' => $section2023A->id,
            ]);

        $response->assertStatus(201);

        // Adviser must be associated with Batch 2023 (not arbitrary Batch 2021)
        $createdAdviser = User::where('email', 'adviser.sea@uetmardan.edu.pk')->first();
        $this->assertNotNull($createdAdviser);
        $this->assertEquals($batch2023->id, $createdAdviser->batch_id);
        $this->assertEquals($section2023A->id, $createdAdviser->section_id);
    }
}
