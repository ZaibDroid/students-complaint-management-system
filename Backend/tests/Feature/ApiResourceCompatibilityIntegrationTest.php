<?php

namespace Tests\Feature;

use App\Models\ApplicationCategory;
use App\Models\Batch;
use App\Models\Campus;
use App\Models\Department;
use App\Models\Faculty;
use App\Models\Section;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ApiResourceCompatibilityIntegrationTest extends TestCase
{
    use RefreshDatabase;

    protected Department $department;
    protected Batch $batch;
    protected Section $section;
    protected User $student;
    protected User $adviser;
    protected User $coordinator;
    protected ApplicationCategory $category;

    protected function setUp(): void
    {
        parent::setUp();

        Storage::fake('public');
        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);

        $campus = Campus::create(['name' => 'Main Campus', 'code' => 'MC']);
        $faculty = Faculty::create(['campus_id' => $campus->id, 'name' => 'Engineering', 'code' => 'ENG']);
        $this->department = Department::create(['faculty_id' => $faculty->id, 'name' => 'Computer Science', 'code' => 'CS']);

        $this->batch = Batch::create(['name' => '2023', 'start_year' => 2023, 'end_year' => 2027]);
        $this->section = Section::create(['batch_id' => $this->batch->id, 'name' => 'A']);

        $this->adviser = User::factory()->create([
            'department_id' => $this->department->id,
            'name' => 'Adviser Usman',
            'email' => 'adviser.usman@uetmardan.edu.pk',
        ]);
        $this->adviser->assignRole('Batch Adviser');

        $this->coordinator = User::factory()->create([
            'department_id' => $this->department->id,
            'name' => 'Coordinator Tariq',
            'email' => 'coordinator.tariq@uetmardan.edu.pk',
        ]);
        $this->coordinator->assignRole('Coordinator');

        $this->student = User::factory()->create([
            'department_id' => $this->department->id,
            'batch_id' => $this->batch->id,
            'section_id' => $this->section->id,
            'name' => 'Bilal Khan',
            'email' => '23mdbcs888@uetmardan.edu.pk',
            'registration_number' => '23MDBCS888',
            'current_semester' => 3,
            'adviser_id' => $this->adviser->id,
            'status' => 'approved',
        ]);
        $this->student->assignRole('Student');

        $this->category = ApplicationCategory::create([
            'name' => 'Scholarship & Fee',
            'slug' => 'scholarship-fee',
            'is_active' => true,
        ]);
    }

    public function test_application_api_returns_complete_payload_matching_flutter_model()
    {
        $file1 = UploadedFile::fake()->create('voucher.pdf', 500, 'application/pdf');
        $file2 = UploadedFile::fake()->create('id_card.png', 200, 'image/png');

        // 1. Submit complaint via API
        $createResponse = $this->actingAs($this->student, 'sanctum')->postJson('/api/v1/applications', [
            'title' => 'Ehsaas Scholarship Voucher Submission',
            'description' => 'Attached proof of scholarship award and bank voucher.',
            'category_id' => $this->category->id,
            'attachments' => [$file1, $file2],
        ]);

        $createResponse->assertStatus(201);
        $appId = $createResponse->json('data.id');

        // 2. Fetch complaint details via API
        $response = $this->actingAs($this->student, 'sanctum')->getJson("/api/v1/applications/{$appId}");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'id',
                    'ticket_number',
                    'department_id',
                    'department_name',
                    'student_id',
                    'studentId',
                    'student_name',
                    'studentName',
                    'title',
                    'description',
                    'category',
                    'status',
                    'priority',
                    'admin_remarks',
                    'adminRemarks',
                    'assigned_to',
                    'assignedTo',
                    'assigned_to_id',
                    'assignedToId',
                    'student_batch',
                    'studentBatch',
                    'attachments',
                    'remarks',
                    'timeline',
                    'created_at',
                    'createdAt',
                    'updated_at',
                    'updatedAt',
                ],
            ]);

        $data = $response->json('data');

        // Verify attachments array contains 2 valid URLs ending with correct extensions
        $this->assertCount(2, $data['attachments']);
        $this->assertStringEndsWith('.pdf', $data['attachments'][0]);
        $this->assertStringEndsWith('.png', $data['attachments'][1]);

        $this->assertDatabaseHas('application_attachments', ['application_id' => $appId, 'file_name' => 'voucher.pdf']);
        $this->assertDatabaseHas('application_attachments', ['application_id' => $appId, 'file_name' => 'id_card.png']);

        // Verify department linkage
        $this->assertEquals((string)$this->department->id, $data['department_id']);
        $this->assertEquals('Computer Science', $data['department_name']);

        // Verify Flutter camelCase mirrors
        $this->assertEquals((string)$this->student->id, $data['studentId']);
        $this->assertEquals('Bilal Khan', $data['studentName']);
        $this->assertEquals('Adviser Usman', $data['assignedTo']);
        $this->assertEquals('2023', $data['studentBatch']);
    }

    public function test_admin_remarks_fallback_to_latest_remark_when_transitioning_status()
    {
        // 1. Submit complaint
        $createResponse = $this->actingAs($this->student, 'sanctum')->postJson('/api/v1/applications', [
            'title' => 'DMC Correction',
            'description' => 'Father name misspelling on transcript',
            'category_id' => $this->category->id,
        ]);
        $appId = $createResponse->json('data.id');

        // 2. Adviser forwards with note
        $forwardNote = 'Forwarded to Department Coordinator for record revision.';
        $this->actingAs($this->adviser, 'sanctum')->putJson("/api/v1/applications/{$appId}/status", [
            'status' => 'forwarded',
            'assigned_to_id' => $this->coordinator->id,
            'notes' => $forwardNote,
        ])->assertStatus(200);

        $getAfterForward = $this->actingAs($this->student, 'sanctum')->getJson("/api/v1/applications/{$appId}");
        $this->assertEquals($forwardNote, $getAfterForward->json('data.admin_remarks'));
        $this->assertEquals($forwardNote, $getAfterForward->json('data.adminRemarks'));

        // 3. Coordinator resolves with note
        $resolveNote = 'Corrected DMC printed and sent to academic office.';
        $this->actingAs($this->coordinator, 'sanctum')->putJson("/api/v1/applications/{$appId}/status", [
            'status' => 'resolved',
            'notes' => $resolveNote,
        ])->assertStatus(200);

        $getAfterResolve = $this->actingAs($this->student, 'sanctum')->getJson("/api/v1/applications/{$appId}");
        $this->assertEquals($resolveNote, $getAfterResolve->json('data.admin_remarks'));
        $this->assertEquals($resolveNote, $getAfterResolve->json('data.adminRemarks'));
        $this->assertCount(2, $getAfterResolve->json('data.remarks'));
    }

    public function test_auth_profile_and_me_endpoints_return_flutter_compatible_user_schema()
    {
        $response = $this->actingAs($this->student, 'sanctum')->getJson('/api/v1/auth/me');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'id',
                    'name',
                    'email',
                    'role',
                    'registration_number',
                    'registrationNumber',
                    'department',
                    'batch',
                    'section',
                    'current_semester',
                    'currentSemester',
                    'year',
                    'semester',
                    'adviser',
                    'is_cr',
                    'isCR',
                    'status',
                ],
            ]);

        $data = $response->json('data');

        $this->assertEquals('23MDBCS888', $data['registrationNumber']);
        $this->assertEquals('Computer Science', $data['department']);
        $this->assertEquals('2023', $data['batch']);
        $this->assertEquals('A', $data['section']);
        $this->assertEquals(3, $data['currentSemester']);
        $this->assertEquals('Semester 3', $data['year']);
        $this->assertEquals('Semester 3', $data['semester']);
        $this->assertEquals('Adviser Usman', $data['adviser']);
        $this->assertFalse($data['isCR']);
    }
}
