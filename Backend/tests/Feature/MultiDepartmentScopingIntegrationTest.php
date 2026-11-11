<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\Batch;
use App\Models\Campus;
use App\Models\Department;
use App\Models\Faculty;
use App\Models\Notice;
use App\Models\Section;
use App\Models\User;
use App\Repositories\ApplicationRepository;
use App\Repositories\NoticeRepository;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MultiDepartmentScopingIntegrationTest extends TestCase
{
    use RefreshDatabase;

    protected Department $dept1;
    protected Department $dept2;
    protected User $coordinatorDept1;
    protected User $chairmanDept2;
    protected User $adviserDept1;
    protected Batch $batch;
    protected Section $sectionA;
    protected Section $sectionB;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);

        $campus = Campus::create(['name' => 'Main Campus', 'code' => 'MC']);
        $faculty = Faculty::create(['campus_id' => $campus->id, 'name' => 'Engineering', 'code' => 'ENG']);
        $this->dept1 = Department::create(['faculty_id' => $faculty->id, 'name' => 'Computer Science', 'code' => 'CS']);
        $this->dept2 = Department::create(['faculty_id' => $faculty->id, 'name' => 'Electrical Engineering', 'code' => 'EE']);

        $this->batch = Batch::create(['name' => '2023', 'start_year' => 2023, 'end_year' => 2027]);
        $this->sectionA = Section::create(['batch_id' => $this->batch->id, 'name' => 'A']);
        $this->sectionB = Section::create(['batch_id' => $this->batch->id, 'name' => 'B']);

        $this->coordinatorDept1 = User::factory()->create([
            'email' => 'coord.cs@uetmardan.edu.pk',
            'department_id' => $this->dept1->id,
            'status' => 'approved',
        ]);
        $this->coordinatorDept1->assignRole('Coordinator');

        $this->chairmanDept2 = User::factory()->create([
            'email' => 'chair.ee@uetmardan.edu.pk',
            'department_id' => $this->dept2->id,
            'status' => 'approved',
        ]);
        $this->chairmanDept2->assignRole('Chairman');

        $this->adviserDept1 = User::factory()->create([
            'email' => 'adviser.cs@uetmardan.edu.pk',
            'department_id' => $this->dept1->id,
            'status' => 'approved',
        ]);
        $this->adviserDept1->assignRole('Batch Adviser');
        $this->adviserDept1->assignedSections()->attach($this->sectionA->id);
    }

    public function test_application_repository_filters_complaints_strictly_by_department_for_chairman_and_coordinator()
    {
        $studentDept1 = User::factory()->create(['department_id' => $this->dept1->id]);
        $studentDept1->assignRole('Student');

        $studentDept2 = User::factory()->create(['department_id' => $this->dept2->id]);
        $studentDept2->assignRole('Student');

        $appDept1 = Application::factory()->create([
            'department_id' => $this->dept1->id,
            'student_id' => $studentDept1->id,
            'title' => 'CS Dept Complaint',
        ]);

        $appDept2 = Application::factory()->create([
            'department_id' => $this->dept2->id,
            'student_id' => $studentDept2->id,
            'title' => 'EE Dept Complaint',
        ]);

        /** @var ApplicationRepository $repo */
        $repo = app(ApplicationRepository::class);

        // Coordinator Dept 1 queries complaints
        $coordResults = $repo->getApplicationsForUser($this->coordinatorDept1);
        $this->assertCount(1, $coordResults->items());
        $this->assertEquals($appDept1->id, $coordResults->items()[0]->id);

        // Chairman Dept 2 queries complaints
        $chairResults = $repo->getApplicationsForUser($this->chairmanDept2);
        $this->assertCount(1, $chairResults->items());
        $this->assertEquals($appDept2->id, $chairResults->items()[0]->id);
    }

    public function test_batch_adviser_accesses_directly_assigned_and_section_student_complaints_only()
    {
        $studentSecA = User::factory()->create([
            'department_id' => $this->dept1->id,
            'batch_id' => $this->batch->id,
            'section_id' => $this->sectionA->id,
        ]);
        $studentSecA->assignRole('Student');

        $studentSecB = User::factory()->create([
            'department_id' => $this->dept1->id,
            'batch_id' => $this->batch->id,
            'section_id' => $this->sectionB->id,
        ]);
        $studentSecB->assignRole('Student');

        // 1. Complaint submitted by student in section A (assigned section)
        $appSecA = Application::factory()->create([
            'department_id' => $this->dept1->id,
            'student_id' => $studentSecA->id,
            'assigned_to_id' => null,
            'title' => 'Complaint from Section A student',
        ]);

        // 2. Complaint directly assigned to this adviser
        $otherStudent = User::factory()->create(['department_id' => $this->dept1->id]);
        $appDirect = Application::factory()->create([
            'department_id' => $this->dept1->id,
            'student_id' => $otherStudent->id,
            'assigned_to_id' => $this->adviserDept1->id,
            'title' => 'Directly assigned complaint',
        ]);

        // 3. Complaint from student in Section B (unassigned section)
        $appSecB = Application::factory()->create([
            'department_id' => $this->dept1->id,
            'student_id' => $studentSecB->id,
            'assigned_to_id' => null,
            'title' => 'Complaint from Section B student',
        ]);

        /** @var ApplicationRepository $repo */
        $repo = app(ApplicationRepository::class);
        $adviserResults = $repo->getApplicationsForUser($this->adviserDept1);
        $adviserAppIds = collect($adviserResults->items())->pluck('id')->all();

        $this->assertContains($appSecA->id, $adviserAppIds);
        $this->assertContains($appDirect->id, $adviserAppIds);
        $this->assertNotContains($appSecB->id, $adviserAppIds);
    }

    public function test_cross_department_access_via_api_is_blocked_with_403()
    {
        $studentDept2 = User::factory()->create(['department_id' => $this->dept2->id]);
        $studentDept2->assignRole('Student');

        $appDept2 = Application::factory()->create([
            'department_id' => $this->dept2->id,
            'student_id' => $studentDept2->id,
            'title' => 'EE Confidential Issue',
        ]);

        // 1. Coordinator Dept 1 attempts to view EE Complaint -> 403 Forbidden
        $responseView = $this->actingAs($this->coordinatorDept1, 'sanctum')
            ->getJson("/api/v1/applications/{$appDept2->id}");

        $responseView->assertStatus(403);

        // 2. Coordinator Dept 1 attempts to update status of EE Complaint -> 403 Forbidden
        $responseStatus = $this->actingAs($this->coordinatorDept1, 'sanctum')
            ->putJson("/api/v1/applications/{$appDept2->id}/status", [
                'status' => 'resolved',
            ]);

        $responseStatus->assertStatus(403);
    }

    public function test_notice_repository_index_filtering_scopes_notices_by_department_and_targets()
    {
        // Notice 1: Global notice
        $globalNotice = Notice::create([
            'sender_id' => $this->coordinatorDept1->id,
            'department_id' => null,
            'title' => 'University Holiday Announcement',
            'description' => 'Campus closed tomorrow',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        // Notice 2: Dept 1 Notice
        $dept1Notice = Notice::create([
            'sender_id' => $this->coordinatorDept1->id,
            'department_id' => $this->dept1->id,
            'title' => 'CS Lab Maintenance',
            'description' => 'Lab 3 closed for upgrade',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        // Notice 3: Dept 2 Notice
        $dept2Notice = Notice::create([
            'sender_id' => $this->chairmanDept2->id,
            'department_id' => $this->dept2->id,
            'title' => 'EE Power Workshop',
            'description' => 'Workshop in EE Hall',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        $studentDept1 = User::factory()->create([
            'department_id' => $this->dept1->id,
            'batch_id' => $this->batch->id,
            'section_id' => $this->sectionA->id,
        ]);
        $studentDept1->assignRole('Student');

        /** @var NoticeRepository $noticeRepo */
        $noticeRepo = app(NoticeRepository::class);
        $studentNotices = $noticeRepo->getNoticesForUser($studentDept1);
        $studentNoticeIds = collect($studentNotices->items())->pluck('id')->all();

        $this->assertContains($globalNotice->id, $studentNoticeIds);
        $this->assertContains($dept1Notice->id, $studentNoticeIds);
        $this->assertNotContains($dept2Notice->id, $studentNoticeIds);
    }
}

