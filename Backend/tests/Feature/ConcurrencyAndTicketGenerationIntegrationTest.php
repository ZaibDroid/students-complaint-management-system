<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\ApplicationAttachment;
use App\Models\ApplicationCategory;
use App\Models\ApplicationRemark;
use App\Models\Campus;
use App\Models\Department;
use App\Models\Faculty;
use App\Models\User;
use App\Services\ApplicationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ConcurrencyAndTicketGenerationIntegrationTest extends TestCase
{
    use RefreshDatabase;

    protected User $student;
    protected User $adviser;
    protected User $coordinator;
    protected Department $department;
    protected ApplicationCategory $category;

    protected function setUp(): void
    {
        parent::setUp();

        Storage::fake('public');

        $campus = Campus::create(['name' => 'Main Campus', 'code' => 'MC']);
        $faculty = Faculty::create(['campus_id' => $campus->id, 'name' => 'Engineering', 'code' => 'ENG']);
        $this->department = Department::create(['faculty_id' => $faculty->id, 'name' => 'Computer Science', 'code' => 'CS']);

        $this->adviser = User::factory()->create([
            'department_id' => $this->department->id,
            'name' => 'Advisor Ali',
        ]);
        $this->adviser->assignRole('Batch Adviser');

        $this->coordinator = User::factory()->create([
            'department_id' => $this->department->id,
            'name' => 'Coordinator Khan',
        ]);
        $this->coordinator->assignRole('Coordinator');

        $this->student = User::factory()->create([
            'department_id' => $this->department->id,
            'adviser_id' => $this->adviser->id,
            'name' => 'Student Ahmad',
            'registration_number' => '23MDBCS514',
            'current_semester' => 4,
        ]);
        $this->student->assignRole('Student');

        $this->category = ApplicationCategory::create([
            'name' => 'Academic Issue',
            'slug' => 'academic-issue',
            'is_active' => true,
        ]);
    }

    public function test_submitting_application_via_api_generates_sequential_ticket_number()
    {
        $year = date('Y');

        $response1 = $this->actingAs($this->student)->postJson('/api/v1/applications', [
            'title' => 'First Complaint',
            'description' => 'Complaint description 1',
            'category_id' => $this->category->id,
        ]);

        $response1->assertStatus(201)
                  ->assertJsonPath('data.ticket_number', "DCMS-{$year}-0001");

        $response2 = $this->actingAs($this->student)->postJson('/api/v1/applications', [
            'title' => 'Second Complaint',
            'description' => 'Complaint description 2',
            'category_id' => $this->category->id,
        ]);

        $response2->assertStatus(201)
                  ->assertJsonPath('data.ticket_number', "DCMS-{$year}-0002");

        $this->assertDatabaseHas('applications', ['ticket_number' => "DCMS-{$year}-0001"]);
        $this->assertDatabaseHas('applications', ['ticket_number' => "DCMS-{$year}-0002"]);
    }

    public function test_multi_file_upload_via_api_stores_all_files_into_application_attachments_table()
    {
        $file1 = UploadedFile::fake()->create('marksheet.pdf', 300, 'application/pdf');
        $file2 = UploadedFile::fake()->create('fee_receipt.png', 400, 'image/png');

        $response = $this->actingAs($this->student)->postJson('/api/v1/applications', [
            'title' => 'Grade Correction with Multi Attachments',
            'description' => 'Attached both my transcript and payment receipt',
            'category_id' => $this->category->id,
            'attachments' => [$file1, $file2],
        ]);

        $response->assertStatus(201);
        $appId = $response->json('data.id');

        $this->assertDatabaseCount('application_attachments', 2);
        $this->assertDatabaseHas('application_attachments', [
            'application_id' => $appId,
            'file_name' => 'marksheet.pdf',
            'file_type' => 'application/pdf',
        ]);
        $this->assertDatabaseHas('application_attachments', [
            'application_id' => $appId,
            'file_name' => 'fee_receipt.png',
            'file_type' => 'image/png',
        ]);

        /** @var Application $app */
        $app = Application::with('attachments')->findOrFail($appId);
        $this->assertCount(2, $app->attachments);
    }

    public function test_status_transition_via_api_automatically_records_official_remark()
    {
        /** @var ApplicationService $service */
        $service = app(ApplicationService::class);
        $app = $service->createApplication($this->student, [
            'title' => 'Subject Registration Error',
            'description' => 'Portal not allowing elective choice',
            'category_id' => $this->category->id,
        ]);

        // 1. Forward to coordinator via API without custom notes
        $response1 = $this->actingAs($this->adviser)->putJson("/api/v1/applications/{$app->id}/status", [
            'status' => 'forwarded',
            'assigned_to_id' => $this->coordinator->id,
        ]);

        $response1->assertStatus(200);

        $this->assertDatabaseHas('application_remarks', [
            'application_id' => $app->id,
            'user_id' => $this->adviser->id,
            'remark' => "Application forwarded to {$this->coordinator->name}",
        ]);

        // 2. Resolve via API with custom notes
        $customResolveNote = 'Course has been manually enrolled by coordinator.';
        $response2 = $this->actingAs($this->coordinator)->putJson("/api/v1/applications/{$app->id}/status", [
            'status' => 'resolved',
            'notes' => $customResolveNote,
        ]);

        $response2->assertStatus(200);

        $this->assertDatabaseHas('application_remarks', [
            'application_id' => $app->id,
            'user_id' => $this->coordinator->id,
            'remark' => $customResolveNote,
        ]);

        // Remarks count should be 2
        $this->assertEquals(2, ApplicationRemark::where('application_id', $app->id)->count());
    }

    public function test_high_volume_consecutive_ticket_generation_maintains_strict_sequence_and_zero_collisions()
    {
        /** @var ApplicationService $service */
        $service = app(ApplicationService::class);
        $year = date('Y');

        $generatedTickets = [];
        for ($i = 1; $i <= 25; $i++) {
            $ticket = $service->generateSequentialTicketNumber();
            $generatedTickets[] = $ticket;
            $expected = sprintf('DCMS-%s-%04d', $year, $i);
            $this->assertEquals($expected, $ticket);
        }

        // All 25 must be distinct
        $this->assertCount(25, array_unique($generatedTickets));

        // Sequence table current value must match 25
        $currentVal = DB::table('ticket_sequences')->where('name', "applications_{$year}")->value('current_value');
        $this->assertEquals(25, $currentVal);
    }
}
