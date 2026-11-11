<?php

namespace Tests\Unit;

use App\Models\Application;
use App\Models\Campus;
use App\Models\Department;
use App\Models\Faculty;
use App\Models\Section;
use App\Models\Batch;
use App\Models\User;
use App\Policies\ApplicationPolicy;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MultiDepartmentScopingUnitTest extends TestCase
{
    use RefreshDatabase;

    protected Department $dept1;
    protected Department $dept2;
    protected ApplicationPolicy $policy;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);

        $campus = Campus::create(['name' => 'Main Campus', 'code' => 'MC']);
        $faculty = Faculty::create(['campus_id' => $campus->id, 'name' => 'Engineering', 'code' => 'ENG']);
        $this->dept1 = Department::create(['faculty_id' => $faculty->id, 'name' => 'Computer Science', 'code' => 'CS']);
        $this->dept2 = Department::create(['faculty_id' => $faculty->id, 'name' => 'Electrical Engineering', 'code' => 'EE']);

        $this->policy = new ApplicationPolicy();
    }

    public function test_application_policy_enforces_department_boundaries_on_view()
    {
        $chairmanDept1 = User::factory()->create(['department_id' => $this->dept1->id]);
        $chairmanDept1->assignRole('Chairman');

        $coordinatorDept1 = User::factory()->create(['department_id' => $this->dept1->id]);
        $coordinatorDept1->assignRole('Coordinator');

        $studentDept1 = User::factory()->create(['department_id' => $this->dept1->id]);
        $studentDept1->assignRole('Student');

        $studentDept2 = User::factory()->create(['department_id' => $this->dept2->id]);
        $studentDept2->assignRole('Student');

        $appDept1 = Application::factory()->create([
            'department_id' => $this->dept1->id,
            'student_id' => $studentDept1->id,
        ]);

        $appDept2 = Application::factory()->create([
            'department_id' => $this->dept2->id,
            'student_id' => $studentDept2->id,
        ]);

        // Chairman Dept 1 CAN view Dept 1 complaint
        $this->assertTrue($this->policy->view($chairmanDept1, $appDept1));

        // Chairman Dept 1 CANNOT view Dept 2 complaint (cross-department boundary)
        $this->assertFalse($this->policy->view($chairmanDept1, $appDept2));

        // Coordinator Dept 1 CAN view Dept 1 complaint
        $this->assertTrue($this->policy->view($coordinatorDept1, $appDept1));

        // Coordinator Dept 1 CANNOT view Dept 2 complaint
        $this->assertFalse($this->policy->view($coordinatorDept1, $appDept2));

        // Student 1 CANNOT view Student 2 complaint
        $this->assertFalse($this->policy->view($studentDept1, $appDept2));
        $this->assertTrue($this->policy->view($studentDept1, $appDept1));
    }

    public function test_application_policy_enforces_department_boundaries_on_update_and_status()
    {
        $chairmanDept1 = User::factory()->create(['department_id' => $this->dept1->id]);
        $chairmanDept1->assignRole('Chairman');

        $coordinatorDept1 = User::factory()->create(['department_id' => $this->dept1->id]);
        $coordinatorDept1->assignRole('Coordinator');

        $adviserDept1 = User::factory()->create(['department_id' => $this->dept1->id]);
        $adviserDept1->assignRole('Batch Adviser');

        $appDept1 = Application::factory()->create([
            'department_id' => $this->dept1->id,
            'assigned_to_id' => $adviserDept1->id,
        ]);

        $appDept2 = Application::factory()->create([
            'department_id' => $this->dept2->id,
            'assigned_to_id' => null,
        ]);

        // Chairman Dept 1 CAN update status of Dept 1 complaint
        $this->assertTrue($this->policy->updateStatus($chairmanDept1, $appDept1));

        // Chairman Dept 1 CANNOT update status of Dept 2 complaint
        $this->assertFalse($this->policy->updateStatus($chairmanDept1, $appDept2));

        // Coordinator Dept 1 CANNOT update status of Dept 2 complaint
        $this->assertFalse($this->policy->updateStatus($coordinatorDept1, $appDept2));

        // Adviser Dept 1 CAN update status of complaint assigned directly to them
        $this->assertTrue($this->policy->updateStatus($adviserDept1, $appDept1));

        // Adviser Dept 1 CANNOT update status of complaint NOT assigned to them
        $this->assertFalse($this->policy->updateStatus($adviserDept1, $appDept2));
    }

    public function test_batch_adviser_can_view_complaints_of_students_in_assigned_batches_and_sections()
    {
        $batch = Batch::create(['name' => '2023', 'start_year' => 2023, 'end_year' => 2027]);
        $sectionA = Section::create(['batch_id' => $batch->id, 'name' => 'A']);
        $sectionB = Section::create(['batch_id' => $batch->id, 'name' => 'B']);

        $adviser = User::factory()->create(['department_id' => $this->dept1->id]);
        $adviser->assignRole('Batch Adviser');
        $adviser->assignedSections()->attach($sectionA->id);

        $studentSecA = User::factory()->create([
            'department_id' => $this->dept1->id,
            'batch_id' => $batch->id,
            'section_id' => $sectionA->id,
        ]);

        $studentSecB = User::factory()->create([
            'department_id' => $this->dept1->id,
            'batch_id' => $batch->id,
            'section_id' => $sectionB->id,
        ]);

        $appFromSecA = Application::factory()->create([
            'department_id' => $this->dept1->id,
            'student_id' => $studentSecA->id,
            'assigned_to_id' => null,
        ]);

        $appFromSecB = Application::factory()->create([
            'department_id' => $this->dept1->id,
            'student_id' => $studentSecB->id,
            'assigned_to_id' => null,
        ]);

        // Adviser CAN view complaint from student in assigned section A
        $this->assertTrue($this->policy->view($adviser, $appFromSecA));

        // Adviser CANNOT view complaint from student in section B (not assigned)
        $this->assertFalse($this->policy->view($adviser, $appFromSecB));
    }
}

