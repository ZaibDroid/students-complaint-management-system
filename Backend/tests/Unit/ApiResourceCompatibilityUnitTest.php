<?php

namespace Tests\Unit;

use App\Http\Resources\ApplicationResource;
use App\Http\Resources\UserResource;
use App\Models\Application;
use App\Models\ApplicationAttachment;
use App\Models\ApplicationCategory;
use App\Models\ApplicationRemark;
use App\Models\Batch;
use App\Models\Campus;
use App\Models\Department;
use App\Models\Faculty;
use App\Models\Section;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Request;
use Tests\TestCase;

class ApiResourceCompatibilityUnitTest extends TestCase
{
    use RefreshDatabase;

    protected Department $department;
    protected Batch $batch;
    protected Section $section;
    protected User $student;
    protected User $adviser;
    protected ApplicationCategory $category;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);

        $campus = Campus::create(['name' => 'Main Campus', 'code' => 'MC']);
        $faculty = Faculty::create(['campus_id' => $campus->id, 'name' => 'Engineering', 'code' => 'ENG']);
        $this->department = Department::create(['faculty_id' => $faculty->id, 'name' => 'Computer Science', 'code' => 'CS']);

        $this->batch = Batch::create(['name' => '2023', 'start_year' => 2023, 'end_year' => 2027]);
        $this->section = Section::create(['batch_id' => $this->batch->id, 'name' => 'A']);

        $this->adviser = User::factory()->create([
            'department_id' => $this->department->id,
            'name' => 'Adviser Dr. Qasim',
        ]);
        $this->adviser->assignRole('Batch Adviser');

        $this->student = User::factory()->create([
            'department_id' => $this->department->id,
            'batch_id' => $this->batch->id,
            'section_id' => $this->section->id,
            'name' => 'Ali Raza',
            'email' => '23mdbcs514@uetmardan.edu.pk',
            'registration_number' => '23MDBCS514',
            'current_semester' => 4,
            'adviser_id' => $this->adviser->id,
        ]);
        $this->student->assignRole('Student');

        $this->category = ApplicationCategory::create([
            'name' => 'Examination Query',
            'slug' => 'examination-query',
            'is_active' => true,
        ]);
    }

    public function test_application_resource_maps_all_flutter_and_laravel_fields_accurately()
    {
        /** @var Application $app */
        $app = Application::create([
            'student_id' => $this->student->id,
            'department_id' => $this->department->id,
            'assigned_to_id' => $this->adviser->id,
            'category_id' => $this->category->id,
            'title' => 'Grade Recalculation Request',
            'description' => 'Midterm score was calculated as 12 instead of 20.',
            'status' => 'pending',
            'priority' => 'high',
        ]);

        // Attach two files via relation
        ApplicationAttachment::create([
            'application_id' => $app->id,
            'file_name' => 'transcript.pdf',
            'file_path' => "Applications/{$app->id}/transcript.pdf",
            'file_type' => 'application/pdf',
            'file_size' => 10240,
        ]);

        ApplicationAttachment::create([
            'application_id' => $app->id,
            'file_name' => 'exam_sheet.jpg',
            'file_path' => "Applications/{$app->id}/exam_sheet.jpg",
            'file_type' => 'image/jpeg',
            'file_size' => 20480,
        ]);

        // Add remark
        ApplicationRemark::create([
            'application_id' => $app->id,
            'user_id' => $this->adviser->id,
            'remark' => 'Verified with teacher. Score revised to 20.',
        ]);

        $app->load(['department', 'attachments', 'student.batch', 'student.section', 'assignedTo', 'category', 'remarks.user']);

        $resource = new ApplicationResource($app);
        $data = $resource->toArray(Request::create('/api/v1/applications/' . $app->id));

        // 1. Verify attachments are URLs
        $this->assertIsArray($data['attachments']);
        $this->assertCount(2, $data['attachments']);
        $this->assertStringContainsString('transcript.pdf', $data['attachments'][0]);
        $this->assertStringContainsString('exam_sheet.jpg', $data['attachments'][1]);

        // 2. Verify admin_remarks / adminRemarks fallback to latest remark
        $this->assertEquals('Verified with teacher. Score revised to 20.', $data['admin_remarks']);
        $this->assertEquals('Verified with teacher. Score revised to 20.', $data['adminRemarks']);

        // 3. Verify department attributes
        $this->assertEquals((string)$this->department->id, $data['department_id']);
        $this->assertEquals((string)$this->department->id, $data['departmentId']);
        $this->assertEquals('Computer Science', $data['department_name']);
        $this->assertEquals('Computer Science', $data['departmentName']);

        // 4. Verify Flutter ComplaintModel compatibility fields
        $this->assertEquals((string)$app->id, $data['id']);
        $this->assertEquals((string)$this->student->id, $data['studentId']);
        $this->assertEquals('Ali Raza', $data['studentName']);
        $this->assertEquals('Examination Query', $data['category']);
        $this->assertEquals('pending', $data['status']);
        $this->assertEquals('high', $data['priority']);
        $this->assertEquals('Adviser Dr. Qasim', $data['assignedTo']);
        $this->assertEquals((string)$this->adviser->id, $data['assignedToId']);
        $this->assertEquals('2023', $data['studentBatch']);
    }

    public function test_user_resource_maps_all_flutter_and_laravel_fields_accurately()
    {
        $this->student->load(['department', 'batch', 'section', 'adviser']);

        $resource = new UserResource($this->student);
        $data = $resource->toArray(Request::create('/api/v1/auth/me'));

        // 1. Identity & Registration
        $this->assertEquals((string)$this->student->id, $data['id']);
        $this->assertEquals('23MDBCS514', $data['registration_number']);
        $this->assertEquals('23MDBCS514', $data['registrationNumber']);
        $this->assertEquals('23MDBCS514', $data['reg_no']);

        // 2. Normalized Semester & String Fallbacks for Flutter User.fromJson
        $this->assertEquals(4, $data['current_semester']);
        $this->assertEquals(4, $data['currentSemester']);
        $this->assertEquals('Semester 4', $data['semester']);
        $this->assertEquals('Semester 4', $data['year']);

        // 3. Institutional Relations
        $this->assertEquals('Computer Science', $data['department']);
        $this->assertEquals((string)$this->department->id, $data['department_id']);
        $this->assertEquals('2023', $data['batch']);
        $this->assertEquals('A', $data['section']);
        $this->assertEquals('Adviser Dr. Qasim', $data['adviser']);

        // 4. Role & CR flags
        $this->assertEquals('Student', $data['role']);
        $this->assertFalse($data['isCR']);
        $this->assertFalse($data['is_cr']);
    }
}

