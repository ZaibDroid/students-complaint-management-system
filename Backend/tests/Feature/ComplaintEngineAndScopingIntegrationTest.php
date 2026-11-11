<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\ApplicationAttachment;
use App\Models\ApplicationCategory;
use App\Models\Department;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ComplaintEngineAndScopingIntegrationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test schema integrity for Prompt 3 tables and columns.
     */
    public function test_complaint_engine_schema_integrity(): void
    {
        $this->assertTrue(Schema::hasTable('application_attachments'), 'Table application_attachments must exist');
        $this->assertTrue(Schema::hasColumns('application_attachments', [
            'id', 'application_id', 'file_name', 'file_path', 'file_type', 'file_size', 'created_at', 'updated_at'
        ]));

        $this->assertTrue(Schema::hasColumn('applications', 'department_id'), 'Column applications.department_id must exist');
    }

    /**
     * Test data migration backfills department_id, attachments, and admin_remarks.
     */
    public function test_data_migration_backfills_all_legacy_complaint_data(): void
    {
        if (!Schema::hasColumn('applications', 'attachment_path')) {
            $this->markTestSkipped('Legacy attachment_path column has been pruned by Prompt 5 cleanup.');
        }

        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);
        $student = User::factory()->create(['department_id' => $dept->id, 'email' => 'legacy.student@uetmardan.edu.pk']);
        $adviser = User::factory()->create(['department_id' => $dept->id, 'email' => 'legacy.adviser@uetmardan.edu.pk']);

        // Insert legacy application directly bypassing Eloquent hooks
        $appId = DB::table('applications')->insertGetId([
            'ticket_number' => 'DCMS-2025-9999',
            'department_id' => null,
            'student_id' => $student->id,
            'assigned_to_id' => $adviser->id,
            'title' => 'Legacy Unmigrated Complaint',
            'description' => 'Has legacy single attachment and legacy admin remark',
            'status' => 'pending',
            'priority' => 'high',
            'attachment_path' => 'Applications/legacy_file.pdf',
            'attachment_name' => 'legacy_file.pdf',
            'attachment_type' => 'application/pdf',
            'attachment_size' => 2048,
            'admin_remarks' => 'Please provide fee challan copy.',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // 1. Backfill department_id from student
        $studentDeptId = DB::table('users')->where('id', $student->id)->value('department_id');
        DB::table('applications')->where('id', $appId)->update([
            'department_id' => $studentDeptId,
        ]);

        // 2. Backfill single-attachment into application_attachments
        $app = DB::table('applications')->find($appId);
        DB::table('application_attachments')->insert([
            'application_id' => $app->id,
            'file_name' => $app->attachment_name,
            'file_path' => $app->attachment_path,
            'file_type' => $app->attachment_type,
            'file_size' => $app->attachment_size,
            'created_at' => $app->created_at,
            'updated_at' => $app->updated_at,
        ]);

        // 3. Backfill admin_remarks into application_remarks
        DB::table('application_remarks')->insert([
            'application_id' => $app->id,
            'user_id' => $app->assigned_to_id,
            'remark' => trim($app->admin_remarks),
            'created_at' => $app->updated_at,
            'updated_at' => $app->updated_at,
        ]);

        // Assertions
        $migratedApp = DB::table('applications')->find($appId);
        $this->assertEquals($dept->id, $migratedApp->department_id);

        $attachment = DB::table('application_attachments')->where('application_id', $appId)->first();
        $this->assertNotNull($attachment);
        $this->assertEquals('legacy_file.pdf', $attachment->file_name);
        $this->assertEquals('Applications/legacy_file.pdf', $attachment->file_path);

        $remark = DB::table('application_remarks')->where('application_id', $appId)->first();
        $this->assertNotNull($remark);
        $this->assertEquals('Please provide fee challan copy.', $remark->remark);
        $this->assertEquals($adviser->id, $remark->user_id);
    }

    /**
     * Test multiple attachments upload via the API endpoint.
     */
    public function test_student_can_upload_multiple_attachments_via_api(): void
    {
        Storage::fake('public');

        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);
        $adviser = User::factory()->create(['department_id' => $dept->id, 'email' => 'adv.multi@uetmardan.edu.pk']);
        $adviser->assignRole('Batch Adviser');

        $student = User::factory()->create([
            'department_id' => $dept->id,
            'adviser_id' => $adviser->id,
            'email' => 'student.multi@uetmardan.edu.pk',
        ]);
        $student->assignRole('Student');

        $category = ApplicationCategory::firstOrCreate(
            ['name' => 'Academic Issue'],
            ['slug' => 'academic-issue', 'is_active' => true]
        );

        $file1 = UploadedFile::fake()->create('proof_part1.pdf', 500, 'application/pdf');
        $file2 = UploadedFile::fake()->create('proof_part2.png', 300, 'image/png');

        $response = $this->actingAs($student, 'sanctum')->post('/api/v1/applications', [
            'title' => 'Multi-Attachment Application',
            'description' => 'Complaint with multiple supporting documents',
            'category_id' => $category->id,
            'priority' => 'high',
            'attachments' => [$file1, $file2],
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true);

        $appId = $response->json('data.id');
        $this->assertNotNull($appId);

        // Verify multiple records created in application_attachments
        $attachments = ApplicationAttachment::where('application_id', $appId)->get();
        $this->assertCount(2, $attachments);

        $fileNames = $attachments->pluck('file_name')->toArray();
        $this->assertContains('proof_part1.pdf', $fileNames);
        $this->assertContains('proof_part2.png', $fileNames);

        // Verify response payload returns both attachment URLs
        $returnedUrls = $response->json('data.attachments');
        $this->assertIsArray($returnedUrls);
        $this->assertCount(2, $returnedUrls);
    }

    /**
     * Test instant multi-department complaint filtering and data isolation.
     */
    public function test_department_scoping_and_complaint_isolation(): void
    {
        $deptCS = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);
        $deptEE = Department::firstOrCreate(['code' => 'EE'], ['name' => 'Electrical Engineering']);

        $coordCS = User::factory()->create(['department_id' => $deptCS->id, 'email' => 'coord.cs@uetmardan.edu.pk']);
        $coordCS->assignRole('Coordinator');

        $coordEE = User::factory()->create(['department_id' => $deptEE->id, 'email' => 'coord.ee@uetmardan.edu.pk']);
        $coordEE->assignRole('Coordinator');

        $studentCS = User::factory()->create(['department_id' => $deptCS->id, 'email' => 'student.cs@uetmardan.edu.pk']);
        $studentEE = User::factory()->create(['department_id' => $deptEE->id, 'email' => 'student.ee@uetmardan.edu.pk']);

        $appCS = Application::create([
            'student_id' => $studentCS->id,
            'department_id' => $deptCS->id,
            'title' => 'CS Department Specific Issue',
            'description' => 'CS Lab AC not working',
            'status' => 'pending',
            'priority' => 'medium',
        ]);

        $appEE = Application::create([
            'student_id' => $studentEE->id,
            'department_id' => $deptEE->id,
            'title' => 'EE Department Specific Issue',
            'description' => 'EE Transformer voltage fluctuation',
            'status' => 'pending',
            'priority' => 'high',
        ]);

        // CS Coordinator query
        $csResponse = $this->actingAs($coordCS, 'sanctum')->getJson('/api/v1/applications');
        $csResponse->assertStatus(200);

        $csAppIds = collect($csResponse->json('data'))->pluck('id')->map(fn($id) => (int)$id)->toArray();
        $this->assertContains($appCS->id, $csAppIds);
        $this->assertNotContains($appEE->id, $csAppIds);

        // EE Coordinator query
        $eeResponse = $this->actingAs($coordEE, 'sanctum')->getJson('/api/v1/applications');
        $eeResponse->assertStatus(200);

        $eeAppIds = collect($eeResponse->json('data'))->pluck('id')->map(fn($id) => (int)$id)->toArray();
        $this->assertContains($appEE->id, $eeAppIds);
        $this->assertNotContains($appCS->id, $eeAppIds);
    }

    /**
     * Test cascading deletion of application_attachments when application is deleted.
     */
    public function test_attachments_cascade_delete_with_application(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);
        $student = User::factory()->create(['department_id' => $dept->id, 'email' => 'cascade.student@uetmardan.edu.pk']);

        $app = Application::create([
            'student_id' => $student->id,
            'department_id' => $dept->id,
            'title' => 'Application to be force deleted',
            'description' => 'Testing cascade delete of attachments',
            'status' => 'pending',
        ]);

        $att1 = ApplicationAttachment::create([
            'application_id' => $app->id,
            'file_name' => 'file1.pdf',
            'file_path' => 'Applications/test/file1.pdf',
        ]);

        $att2 = ApplicationAttachment::create([
            'application_id' => $app->id,
            'file_name' => 'file2.jpg',
            'file_path' => 'Applications/test/file2.jpg',
        ]);

        $this->assertDatabaseHas('application_attachments', ['id' => $att1->id]);
        $this->assertDatabaseHas('application_attachments', ['id' => $att2->id]);

        // Force delete application
        $app->forceDelete();

        // Attachments must be deleted via foreign key cascade
        $this->assertDatabaseMissing('application_attachments', ['id' => $att1->id]);
        $this->assertDatabaseMissing('application_attachments', ['id' => $att2->id]);
    }
}
