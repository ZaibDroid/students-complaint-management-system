<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\ApplicationTimeline;
use App\Models\Batch;
use App\Models\Department;
use App\Models\Notice;
use App\Models\Section;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class AdminManagementAndDepartmentIsolationTest extends TestCase
{
    use RefreshDatabase;

    protected Department $deptCS;
    protected Department $deptCIV;
    protected User $admin1;
    protected User $admin2;
    protected User $chairmanCS;
    protected User $chairmanCIV;
    protected User $coordCS;
    protected User $adviserCS;
    protected User $studentCS;
    protected Batch $batchCS;
    protected Section $secCSA;

    protected function setUp(): void
    {
        parent::setUp();

        foreach (['Admin', 'Super Admin', 'Chairman', 'Coordinator', 'Batch Adviser', 'Batch Advisor', 'Student', 'Office Staff', 'Dean', 'Vice Chancellor'] as $roleName) {
            Role::firstOrCreate(['name' => $roleName, 'guard_name' => 'web']);
            Role::firstOrCreate(['name' => $roleName, 'guard_name' => 'api']);
        }

        $this->deptCS = Department::create(['name' => 'Department of Computer Science', 'code' => 'CS']);
        $this->deptCIV = Department::create(['name' => 'Department of Civil Engineering', 'code' => 'CIV']);

        // Admin accounts
        $this->admin1 = User::factory()->create([
            'name' => 'Primary Admin',
            'email' => 'admin1@uetmardan.edu.pk',
            'password' => Hash::make('123456'),
        ]);
        $this->admin1->assignRole('Admin');

        $this->admin2 = User::factory()->create([
            'name' => 'Secondary Admin',
            'email' => 'admin2@uetmardan.edu.pk',
            'password' => Hash::make('123456'),
        ]);
        $this->admin2->assignRole('Admin');

        // Chairmen
        $this->chairmanCS = User::factory()->create([
            'name' => 'Chairman CS',
            'email' => 'chair.cs@uetmardan.edu.pk',
            'department_id' => $this->deptCS->id,
            'password' => Hash::make('123456'),
        ]);
        $this->chairmanCS->assignRole('Chairman');

        $this->chairmanCIV = User::factory()->create([
            'name' => 'Chairman Civil',
            'email' => 'chair.civ@uetmardan.edu.pk',
            'department_id' => $this->deptCIV->id,
            'password' => Hash::make('123456'),
        ]);
        $this->chairmanCIV->assignRole('Chairman');

        // Coordinator CS
        $this->coordCS = User::factory()->create([
            'name' => 'Coordinator CS',
            'email' => 'coord.cs@uetmardan.edu.pk',
            'department_id' => $this->deptCS->id,
            'password' => Hash::make('123456'),
        ]);
        $this->coordCS->assignRole('Coordinator');

        // Batch & Section
        $this->batchCS = Batch::create([
            'name' => 'Batch 2022-2026',
            'start_year' => 2022,
            'end_year' => 2026,
            'department_id' => $this->deptCS->id,
            'coordinator_id' => $this->coordCS->id,
            'is_active' => true,
        ]);

        $this->secCSA = Section::create([
            'name' => 'A',
            'batch_id' => $this->batchCS->id,
            'is_active' => true,
        ]);

        // Adviser CS
        $this->adviserCS = User::factory()->create([
            'name' => 'Adviser CS',
            'email' => 'adviser.cs@uetmardan.edu.pk',
            'department_id' => $this->deptCS->id,
            'batch_id' => $this->batchCS->id,
            'section_id' => $this->secCSA->id,
            'password' => Hash::make('123456'),
        ]);
        $this->adviserCS->assignRole('Batch Adviser');
        $this->adviserCS->assignedSections()->sync([$this->secCSA->id]);

        // Student CS
        $this->studentCS = User::factory()->create([
            'name' => 'Student CS User',
            'email' => '22bcs001@uetmardan.edu.pk',
            'department_id' => $this->deptCS->id,
            'batch_id' => $this->batchCS->id,
            'section_id' => $this->secCSA->id,
            'password' => Hash::make('123456'),
        ]);
        $this->studentCS->assignRole('Student');
    }

    // ==========================================
    // 1. ADMIN ACCOUNT PROTECTION
    // ==========================================

    public function test_admin_cannot_delete_own_account()
    {
        $response = $this->actingAs($this->admin1, 'sanctum')
            ->deleteJson("/api/v1/users/staff/{$this->admin1->id}");

        $this->assertTrue(in_array($response->status(), [403, 422]));
        $this->assertDatabaseHas('users', ['id' => $this->admin1->id, 'deleted_at' => null]);
    }

    public function test_admin_can_delete_another_admin_when_multiple_exist()
    {
        $response = $this->actingAs($this->admin1, 'sanctum')
            ->deleteJson("/api/v1/users/staff/{$this->admin2->id}");

        $response->assertStatus(200);
        $this->assertDatabaseMissing('users', ['id' => $this->admin2->id]);
    }

    public function test_cannot_delete_the_last_active_admin_account()
    {
        // First remove secondary admin
        $this->admin2->forceDelete();

        $this->assertEquals(1, User::role('Admin')->count());

        $response = $this->actingAs($this->admin1, 'sanctum')
            ->deleteJson("/api/v1/users/staff/{$this->admin1->id}");

        $this->assertTrue(in_array($response->status(), [403, 422]));
        $this->assertDatabaseHas('users', ['id' => $this->admin1->id]);
    }

    public function test_admin_can_update_their_own_account_details()
    {
        $response = $this->actingAs($this->admin1, 'sanctum')
            ->putJson("/api/v1/users/staff/{$this->admin1->id}", [
                'name' => 'Updated Admin Name',
            ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('users', ['id' => $this->admin1->id, 'name' => 'Updated Admin Name']);
    }

    // ==========================================
    // 2. NOTICE FILTERING CLEANUP
    // ==========================================

    public function test_chairman_departmental_notices_are_excluded_from_admin_view()
    {
        Notice::create([
            'sender_id' => $this->chairmanCS->id,
            'department_id' => $this->deptCS->id,
            'title' => 'Chairman CS Notice',
            'description' => 'Department specific notice',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        Notice::create([
            'sender_id' => $this->admin1->id,
            'department_id' => null,
            'title' => 'University-Wide Admin Notice',
            'description' => 'For everyone',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        $response = $this->actingAs($this->admin1, 'sanctum')
            ->getJson('/api/v1/notices');

        $response->assertStatus(200);
        $titles = collect($response->json('data'))->pluck('title')->toArray();

        $this->assertContains('University-Wide Admin Notice', $titles);
        $this->assertNotContains('Chairman CS Notice', $titles);
    }

    // ==========================================
    // 3. ADMIN STUDENT MANAGEMENT
    // ==========================================

    public function test_admin_can_list_and_search_students()
    {
        $response = $this->actingAs($this->admin1, 'sanctum')
            ->getJson('/api/v1/users/students?search=22bcs001');

        $response->assertStatus(200);
        $this->assertEquals(1, count($response->json('data')));
        $this->assertEquals('Student CS User', $response->json('data.0.name'));
    }

    public function test_admin_can_update_student_details()
    {
        $response = $this->actingAs($this->admin1, 'sanctum')
            ->putJson("/api/v1/users/students/{$this->studentCS->id}", [
                'name' => 'Modified Student Name',
                'email' => '22bcs001@uetmardan.edu.pk',
                'department_id' => $this->deptCS->id,
                'batch_id' => $this->batchCS->id,
                'section_id' => $this->secCSA->id,
            ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('users', ['id' => $this->studentCS->id, 'name' => 'Modified Student Name']);
    }

    public function test_admin_can_reset_student_password_and_it_is_never_exposed()
    {
        $response = $this->actingAs($this->admin1, 'sanctum')
            ->putJson("/api/v1/users/students/{$this->studentCS->id}", [
                'password' => 'newSecretPass123',
            ]);

        $response->assertStatus(200);
        $responseData = $response->json('data');

        $this->assertArrayNotHasKey('password', $responseData);
        $this->assertNull($responseData['assigned_password'] ?? null);

        $freshStudent = User::find($this->studentCS->id);
        $this->assertTrue(Hash::check('newSecretPass123', $freshStudent->password));
    }

    public function test_admin_can_soft_delete_student_preserving_complaints()
    {
        $complaint = Application::create([
            'ticket_number' => 'TCK-TEST-001',
            'student_id' => $this->studentCS->id,
            'department_id' => $this->deptCS->id,
            'assigned_to_id' => $this->adviserCS->id,
            'title' => 'Lab equipment issue',
            'description' => 'Broken monitors in lab 2',
            'status' => 'pending',
            'priority' => 'medium',
        ]);

        $response = $this->actingAs($this->admin1, 'sanctum')
            ->deleteJson("/api/v1/users/students/{$this->studentCS->id}");

        $response->assertStatus(200);

        // Student is soft deleted
        $this->assertSoftDeleted('users', ['id' => $this->studentCS->id]);

        // Complaint remains intact
        $this->assertDatabaseHas('applications', ['id' => $complaint->id]);
    }

    // ==========================================
    // 4. CHAIRMAN ACCOUNT & SUCCESSION
    // ==========================================

    public function test_chairman_creation_requires_mandatory_department()
    {
        $response = $this->actingAs($this->admin1, 'sanctum')
            ->postJson('/api/v1/users/staff', [
                'name' => 'New Chairman Without Dept',
                'email' => 'newchair@uetmardan.edu.pk',
                'password' => '123456',
                'role' => 'Chairman',
            ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['department_id']);
    }

    public function test_chairman_cannot_be_deleted_directly_without_succession()
    {
        $response = $this->actingAs($this->admin1, 'sanctum')
            ->deleteJson("/api/v1/users/staff/{$this->chairmanCS->id}");

        $response->assertStatus(422);
        $this->assertDatabaseHas('users', ['id' => $this->chairmanCS->id]);
    }

    public function test_chairman_succession_atomically_transfers_complaints_and_leadership()
    {
        $complaint = Application::create([
            'ticket_number' => 'TCK-CHAIR-001',
            'student_id' => $this->studentCS->id,
            'department_id' => $this->deptCS->id,
            'assigned_to_id' => $this->chairmanCS->id,
            'title' => 'Appeal to Chairman',
            'description' => 'Grade appeal',
            'status' => 'under_review',
            'priority' => 'high',
        ]);

        // Successor from the same department (e.g. Coordinator or Faculty)
        $successor = User::factory()->create([
            'name' => 'Dr. Successor',
            'email' => 'successor@uetmardan.edu.pk',
            'department_id' => $this->deptCS->id,
            'password' => Hash::make('123456'),
        ]);
        $successor->assignRole('Office Staff');

        $response = $this->actingAs($this->admin1, 'sanctum')
            ->postJson("/api/v1/users/chairmen/{$this->chairmanCS->id}/replace", [
                'replacement_chairman_id' => $successor->id,
            ]);

        $response->assertStatus(200);

        // 1. Complaint reassigned to successor
        $this->assertDatabaseHas('applications', [
            'id' => $complaint->id,
            'assigned_to_id' => $successor->id,
        ]);

        // 2. Timeline logged
        $this->assertDatabaseHas('application_timeline', [
            'application_id' => $complaint->id,
            'action' => 'Chairman Succession',
            'from_user_id' => $this->chairmanCS->id,
            'to_user_id' => $successor->id,
        ]);

        // 3. Successor has Chairman role
        $this->assertTrue($successor->fresh()->hasRole('Chairman'));

        // 4. Old Chairman soft deleted
        $this->assertSoftDeleted('users', ['id' => $this->chairmanCS->id]);
    }

    public function test_chairman_succession_fails_if_replacement_is_from_another_department()
    {
        $response = $this->actingAs($this->admin1, 'sanctum')
            ->postJson("/api/v1/users/chairmen/{$this->chairmanCS->id}/replace", [
                'replacement_chairman_id' => $this->chairmanCIV->id,
            ]);

        $response->assertStatus(422);
    }

    // ==========================================
    // 5. DEPARTMENT MULTI-TENANCY & INHERITANCE
    // ==========================================

    public function test_chairman_creates_coordinator_inheriting_department()
    {
        $response = $this->actingAs($this->chairmanCS, 'sanctum')
            ->postJson('/api/v1/users/staff', [
                'name' => 'New CS Coordinator',
                'email' => 'newcs.coord@uetmardan.edu.pk',
                'password' => '123456',
                'role' => 'Coordinator',
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('users', [
            'email' => 'newcs.coord@uetmardan.edu.pk',
            'department_id' => $this->deptCS->id,
        ]);
    }

    public function test_coordinator_creates_batch_adviser_inheriting_department()
    {
        $response = $this->actingAs($this->coordCS, 'sanctum')
            ->postJson('/api/v1/users/staff', [
                'name' => 'New CS Adviser',
                'email' => 'newcs.adviser@uetmardan.edu.pk',
                'password' => '123456',
                'role' => 'Batch Adviser',
                'batch_id' => $this->batchCS->id,
                'section_id' => $this->secCSA->id,
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('users', [
            'email' => 'newcs.adviser@uetmardan.edu.pk',
            'department_id' => $this->deptCS->id,
        ]);
    }

    // ==========================================
    // 6. STUDENT REGISTRATION VALIDATION
    // ==========================================

    public function test_student_registration_requires_valid_department_and_matching_batch()
    {
        // 1. Missing department
        $resNoDept = $this->postJson('/api/v1/auth/register', [
            'name' => 'Test Student',
            'email' => '22bcs999@uetmardan.edu.pk',
            'password' => '123456',
            'batch_id' => $this->batchCS->id,
            'section_id' => $this->secCSA->id,
        ]);
        $resNoDept->assertStatus(422);

        // 2. Mismatched batch and department
        $resMismatch = $this->postJson('/api/v1/auth/register', [
            'name' => 'Test Student',
            'email' => '22bcs998@uetmardan.edu.pk',
            'password' => '123456',
            'department_id' => $this->deptCIV->id,
            'batch_id' => $this->batchCS->id,
            'section_id' => $this->secCSA->id,
        ]);
        $resMismatch->assertStatus(422);

        // 3. Valid registration
        $resValid = $this->postJson('/api/v1/auth/register', [
            'name' => 'Valid Student',
            'email' => '22bcs997@uetmardan.edu.pk',
            'password' => '123456',
            'department_id' => $this->deptCS->id,
            'batch_id' => $this->batchCS->id,
            'section_id' => $this->secCSA->id,
        ]);
        $this->assertTrue(in_array($resValid->status(), [200, 201]));
        $this->assertDatabaseHas('users', [
            'email' => '22BCS997@uetmardan.edu.pk',
            'department_id' => $this->deptCS->id,
            'status' => 'unlinked',
        ]);
    }

    // ==========================================
    // 7. COMPLAINT FORWARDING & DATA ISOLATION
    // ==========================================

    public function test_complaint_cannot_be_forwarded_across_departments()
    {
        $complaint = Application::create([
            'ticket_number' => 'TCK-DEPT-001',
            'student_id' => $this->studentCS->id,
            'department_id' => $this->deptCS->id,
            'assigned_to_id' => $this->adviserCS->id,
            'title' => 'CS Complaint',
            'description' => 'Test CS',
            'status' => 'pending',
            'priority' => 'low',
        ]);

        $appService = app(\App\Contracts\Services\ApplicationServiceInterface::class);

        // Attempting to forward to Chairman of Civil department
        $this->expectException(\App\Exceptions\ApiException::class);
        $appService->forward($this->adviserCS, $complaint, $this->chairmanCIV, 'Cross-department attempt');
    }

    public function test_forward_recipients_only_includes_department_staff()
    {
        $complaint = Application::create([
            'ticket_number' => 'TCK-REC-001',
            'student_id' => $this->studentCS->id,
            'department_id' => $this->deptCS->id,
            'assigned_to_id' => $this->adviserCS->id,
            'title' => 'Recipients Test',
            'description' => 'Test',
            'status' => 'pending',
            'priority' => 'low',
        ]);

        $response = $this->actingAs($this->adviserCS, 'sanctum')
            ->getJson("/api/v1/applications/{$complaint->id}/recipients");

        $response->assertStatus(200);
        $recipientIds = collect($response->json('data.recipients'))->pluck('id')->toArray();

        $this->assertContains((string)$this->coordCS->id, $recipientIds);
        $this->assertContains((string)$this->chairmanCS->id, $recipientIds);
        $this->assertNotContains((string)$this->chairmanCIV->id, $recipientIds);
    }

    public function test_admin_dashboard_metrics_exclude_chairman_notices()
    {
        Notice::create([
            'sender_id' => $this->chairmanCS->id,
            'department_id' => $this->deptCS->id,
            'title' => 'Chairman CS Notice',
            'description' => 'Department notice',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        Notice::create([
            'sender_id' => $this->admin1->id,
            'department_id' => null,
            'title' => 'Admin System Notice',
            'description' => 'System wide',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        $dashboardRepo = app(\App\Contracts\Repositories\DashboardRepositoryInterface::class);
        $adminDashboard = $dashboardRepo->getAdminDashboard();

        $this->assertEquals(1, $adminDashboard['metrics']['notices']);
    }

    public function test_admin_can_filter_students_by_department()
    {
        $studentCIV = User::factory()->create([
            'name' => 'Civil Student',
            'email' => '22civ001@uetmardan.edu.pk',
            'department_id' => $this->deptCIV->id,
        ]);
        $studentCIV->assignRole('Student');

        $response = $this->actingAs($this->admin1, 'sanctum')
            ->getJson("/api/v1/users/students?department_id={$this->deptCS->id}");

        $response->assertStatus(200);
        $emails = collect($response->json('data'))->pluck('email')->map(fn($e) => strtolower($e))->toArray();
        $this->assertContains('22bcs001@uetmardan.edu.pk', $emails);
        $this->assertNotContains('22civ001@uetmardan.edu.pk', $emails);
    }

    public function test_admin_update_student_validations()
    {
        // 1. Invalid email domain
        $resBadEmail = $this->actingAs($this->admin1, 'sanctum')
            ->putJson("/api/v1/users/students/{$this->studentCS->id}", [
                'email' => 'student@gmail.com',
            ]);
        $resBadEmail->assertStatus(422);

        // 2. Password under 6 characters
        $resShortPass = $this->actingAs($this->admin1, 'sanctum')
            ->putJson("/api/v1/users/students/{$this->studentCS->id}", [
                'password' => '123',
            ]);
        $resShortPass->assertStatus(422);

        // 3. Batch from different department
        $resMismatchedBatch = $this->actingAs($this->admin1, 'sanctum')
            ->putJson("/api/v1/users/students/{$this->studentCS->id}", [
                'department_id' => $this->deptCIV->id,
                'batch_id' => $this->batchCS->id,
            ]);
        $resMismatchedBatch->assertStatus(422);
    }

    public function test_chairman_edit_department_restrictions()
    {
        // 1. Changing department with active assigned complaints fails
        $complaint = Application::create([
            'ticket_number' => 'TCK-ACT-001',
            'student_id' => $this->studentCS->id,
            'department_id' => $this->deptCS->id,
            'assigned_to_id' => $this->chairmanCS->id,
            'title' => 'Active Complaint',
            'description' => 'Test',
            'status' => 'under_review',
            'priority' => 'high',
        ]);

        $resBlocked = $this->actingAs($this->admin1, 'sanctum')
            ->putJson("/api/v1/users/staff/{$this->chairmanCS->id}", [
                'department_id' => $this->deptCIV->id,
            ]);
        $resBlocked->assertStatus(422);

        // 2. Changing department when no active complaints succeeds
        $complaint->update(['status' => 'resolved']);
        $resAllowed = $this->actingAs($this->admin1, 'sanctum')
            ->putJson("/api/v1/users/staff/{$this->chairmanCS->id}", [
                'department_id' => $this->deptCIV->id,
            ]);
        $resAllowed->assertStatus(200);
    }

    public function test_chairman_succession_rejects_self_replacement()
    {
        $response = $this->actingAs($this->admin1, 'sanctum')
            ->postJson("/api/v1/users/chairmen/{$this->chairmanCS->id}/replace", [
                'replacement_chairman_id' => $this->chairmanCS->id,
            ]);

        $response->assertStatus(422);
    }

    public function test_chairman_candidates_only_from_same_department()
    {
        $facultyCS = User::factory()->create([
            'name' => 'Faculty CS Member',
            'email' => 'faculty.cs@uetmardan.edu.pk',
            'department_id' => $this->deptCS->id,
        ]);
        $facultyCS->assignRole('Office Staff');

        $response = $this->actingAs($this->admin1, 'sanctum')
            ->getJson("/api/v1/users/chairmen/{$this->chairmanCS->id}/replacement-candidates");

        $response->assertStatus(200);
        $candidateIds = collect($response->json('data'))->pluck('id')->toArray();

        $this->assertContains($facultyCS->id, $candidateIds);
        $this->assertContains($this->coordCS->id, $candidateIds);
        $this->assertNotContains($this->chairmanCIV->id, $candidateIds);
        $this->assertNotContains($this->studentCS->id, $candidateIds);
    }

    public function test_department_data_isolation_across_roles()
    {
        $complaintCS = Application::create([
            'ticket_number' => 'TCK-CS-001',
            'student_id' => $this->studentCS->id,
            'department_id' => $this->deptCS->id,
            'assigned_to_id' => $this->adviserCS->id,
            'title' => 'CS Complaint',
            'description' => 'Test',
            'status' => 'pending',
            'priority' => 'low',
        ]);

        $appRepo = app(\App\Contracts\Repositories\ApplicationRepositoryInterface::class);

        // Chairman CIV cannot view CS complaints
        $civApps = $appRepo->getApplicationsForUser($this->chairmanCIV);
        $this->assertFalse(collect($civApps->items())->contains('id', $complaintCS->id));

        // Chairman CS can view CS complaints
        $csApps = $appRepo->getApplicationsForUser($this->chairmanCS);
        $this->assertTrue(collect($csApps->items())->contains('id', $complaintCS->id));

        // Admin can view complaints across all departments
        $adminApps = $appRepo->getApplicationsForUser($this->admin1);
        $this->assertTrue(collect($adminApps->items())->contains('id', $complaintCS->id));
    }

    public function test_coordinator_data_isolation_across_departments_and_batches()
    {
        $batchCIV = Batch::create([
            'name' => 'CIV 2022-2026',
            'start_year' => 2022,
            'end_year' => 2026,
            'department_id' => $this->deptCIV->id,
            'is_active' => true,
        ]);
        $secCIV = Section::create([
            'name' => 'A',
            'batch_id' => $batchCIV->id,
            'is_active' => true,
        ]);
        $studentCIV = User::factory()->create([
            'name' => 'CIV Student',
            'email' => '22civ002@uetmardan.edu.pk',
            'department_id' => $this->deptCIV->id,
            'batch_id' => $batchCIV->id,
            'section_id' => $secCIV->id,
        ]);
        $studentCIV->assignRole('Student');

        $complaintCIV = Application::create([
            'ticket_number' => 'TCK-CIV-001',
            'student_id' => $studentCIV->id,
            'department_id' => $this->deptCIV->id,
            'title' => 'CIV Complaint',
            'description' => 'Test CIV',
            'status' => 'pending',
            'priority' => 'medium',
        ]);

        $appRepo = app(\App\Contracts\Repositories\ApplicationRepositoryInterface::class);
        $coordApps = $appRepo->getApplicationsForUser($this->coordCS);

        $this->assertFalse(collect($coordApps->items())->contains('id', $complaintCIV->id));
    }

    public function test_adviser_data_isolation_across_departments()
    {
        $batchCIV = Batch::create([
            'name' => 'CIV 2022-2026',
            'start_year' => 2022,
            'end_year' => 2026,
            'department_id' => $this->deptCIV->id,
            'is_active' => true,
        ]);
        $secCIV = Section::create([
            'name' => 'A',
            'batch_id' => $batchCIV->id,
            'is_active' => true,
        ]);
        $studentCIV = User::factory()->create([
            'name' => 'CIV Student',
            'email' => '22civ003@uetmardan.edu.pk',
            'department_id' => $this->deptCIV->id,
            'batch_id' => $batchCIV->id,
            'section_id' => $secCIV->id,
        ]);
        $studentCIV->assignRole('Student');

        $complaintCIV = Application::create([
            'ticket_number' => 'TCK-CIV-002',
            'student_id' => $studentCIV->id,
            'department_id' => $this->deptCIV->id,
            'title' => 'CIV Complaint',
            'description' => 'Test CIV',
            'status' => 'pending',
            'priority' => 'low',
        ]);

        $appRepo = app(\App\Contracts\Repositories\ApplicationRepositoryInterface::class);
        $adviserApps = $appRepo->getApplicationsForUser($this->adviserCS);

        $this->assertFalse(collect($adviserApps->items())->contains('id', $complaintCIV->id));
    }

    public function test_student_registration_does_not_autocreate_departments()
    {
        $initialDeptCount = Department::count();

        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Fake Student',
            'email' => '22fake001@uetmardan.edu.pk',
            'password' => '123456',
            'department' => 'Non Existent Department',
            'batch_id' => 99999,
            'section_id' => 99999,
        ]);

        $response->assertStatus(422);
        $this->assertEquals($initialDeptCount, Department::count());
    }
}

