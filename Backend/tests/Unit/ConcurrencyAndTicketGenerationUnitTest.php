<?php

namespace Tests\Unit;

use App\Models\Application;
use App\Models\ApplicationCategory;
use App\Models\Department;
use App\Models\Faculty;
use App\Models\Campus;
use App\Models\User;
use App\Services\ApplicationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class ConcurrencyAndTicketGenerationUnitTest extends TestCase
{
    use RefreshDatabase;

    protected User $student;
    protected User $adviser;
    protected User $coordinator;
    protected ApplicationCategory $category;
    protected ApplicationService $applicationService;

    protected function setUp(): void
    {
        parent::setUp();

        $campus = Campus::create(['name' => 'Main Campus', 'code' => 'MC']);
        $faculty = Faculty::create(['campus_id' => $campus->id, 'name' => 'Engineering', 'code' => 'ENG']);
        $department = Department::create(['faculty_id' => $faculty->id, 'name' => 'Computer Science', 'code' => 'CS']);

        $this->adviser = User::factory()->create([
            'department_id' => $department->id,
            'name' => 'Advisor Ali',
        ]);
        $this->adviser->assignRole('Batch Adviser');

        $this->coordinator = User::factory()->create([
            'department_id' => $department->id,
            'name' => 'Coordinator Khan',
        ]);
        $this->coordinator->assignRole('Coordinator');

        $this->student = User::factory()->create([
            'department_id' => $department->id,
            'adviser_id' => $this->adviser->id,
            'name' => 'Student Ahmad',
        ]);
        $this->student->assignRole('Student');

        $this->category = ApplicationCategory::create([
            'name' => 'Exams',
            'slug' => 'exams',
            'is_active' => true,
        ]);

        $this->applicationService = app(ApplicationService::class);
    }

    public function test_model_boot_generates_collision_free_ticket_without_latest_id_query()
    {
        $app1 = Application::create([
            'student_id' => $this->student->id,
            'assigned_to_id' => $this->adviser->id,
            'category_id' => $this->category->id,
            'title' => 'Direct Creation 1',
            'description' => 'Direct Eloquent creation test',
            'status' => 'pending',
        ]);

        $app2 = Application::create([
            'student_id' => $this->student->id,
            'assigned_to_id' => $this->adviser->id,
            'category_id' => $this->category->id,
            'title' => 'Direct Creation 2',
            'description' => 'Direct Eloquent creation test',
            'status' => 'pending',
        ]);

        $this->assertNotEmpty($app1->ticket_number);
        $this->assertNotEmpty($app2->ticket_number);
        $this->assertNotEquals($app1->ticket_number, $app2->ticket_number);
        $this->assertStringStartsWith('DCMS-' . date('Y') . '-', $app1->ticket_number);
        $this->assertStringStartsWith('DCMS-' . date('Y') . '-', $app2->ticket_number);
    }

    public function test_service_generates_atomic_sequential_ticket_numbers()
    {
        $ticket1 = $this->applicationService->generateSequentialTicketNumber();
        $ticket2 = $this->applicationService->generateSequentialTicketNumber();
        $ticket3 = $this->applicationService->generateSequentialTicketNumber();

        $year = date('Y');
        $this->assertEquals("DCMS-{$year}-0001", $ticket1);
        $this->assertEquals("DCMS-{$year}-0002", $ticket2);
        $this->assertEquals("DCMS-{$year}-0003", $ticket3);

        $seqVal = DB::table('ticket_sequences')->where('name', "applications_{$year}")->value('current_value');
        $this->assertEquals(3, $seqVal);
    }

    public function test_status_transitions_automatically_create_application_remarks_even_without_notes()
    {
        /** @var Application $app */
        $app = $this->applicationService->createApplication($this->student, [
            'title' => 'Transcript Delay',
            'description' => 'I have not received my transcript',
            'category_id' => $this->category->id,
        ]);

        $this->assertCount(0, $app->remarks);

        // 1. Forward without notes -> should auto-create remark
        $forwarded = $this->applicationService->forward($this->adviser, $app, $this->coordinator, null);
        $this->assertEquals(Application::STATUS_FORWARDED, $forwarded->status);
        $this->assertCount(1, $forwarded->remarks);
        $this->assertStringContainsString('Coordinator Khan', $forwarded->remarks->first()->remark);

        // 2. Resolve without notes -> should auto-create remark
        $resolved = $this->applicationService->resolve($this->coordinator, $forwarded, null);
        $this->assertEquals(Application::STATUS_RESOLVED, $resolved->status);
        $this->assertCount(2, $resolved->remarks);
        $this->assertStringContainsString('resolved', strtolower($resolved->remarks->last()->remark));
    }

    public function test_status_transitions_preserve_custom_notes_in_application_remarks()
    {
        /** @var Application $app */
        $app = $this->applicationService->createApplication($this->student, [
            'title' => 'Fee Issue',
            'description' => 'Challan fee verification pending',
            'category_id' => $this->category->id,
        ]);

        // Reject with explicit custom note
        $customNote = 'Incorrect payment voucher attached. Please attach bank stamp.';
        $rejected = $this->applicationService->reject($this->adviser, $app, $customNote);

        $this->assertEquals(Application::STATUS_REJECTED, $rejected->status);
        $this->assertCount(1, $rejected->remarks);
        $this->assertEquals($customNote, $rejected->remarks->first()->remark);
        $this->assertEquals($this->adviser->id, $rejected->remarks->first()->user_id);
    }
}

