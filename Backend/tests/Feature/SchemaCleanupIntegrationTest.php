<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\ApplicationCategory;
use App\Models\Department;
use App\Models\Notice;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class SchemaCleanupIntegrationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test dead tables are completely dropped from the database.
     */
    public function test_dead_tables_are_dropped(): void
    {
        $this->assertFalse(Schema::hasTable('media'), 'Table "media" must be dropped');
        $this->assertFalse(Schema::hasTable('login_histories'), 'Table "login_histories" must be dropped');
        $this->assertFalse(Schema::hasTable('notice_targets'), 'Table "notice_targets" must be dropped');
    }

    /**
     * Test redundant columns are completely dropped from their respective tables.
     */
    public function test_redundant_columns_are_dropped(): void
    {
        // Dropped columns on applications
        $this->assertFalse(Schema::hasColumn('applications', 'attachment_path'), 'applications.attachment_path must be dropped');
        $this->assertFalse(Schema::hasColumn('applications', 'attachment_name'), 'applications.attachment_name must be dropped');
        $this->assertFalse(Schema::hasColumn('applications', 'attachment_type'), 'applications.attachment_type must be dropped');
        $this->assertFalse(Schema::hasColumn('applications', 'attachment_size'), 'applications.attachment_size must be dropped');
        $this->assertFalse(Schema::hasColumn('applications', 'admin_remarks'), 'applications.admin_remarks must be dropped');

        // Dropped column on application_remarks
        $this->assertFalse(Schema::hasColumn('application_remarks', 'action_taken'), 'application_remarks.action_taken must be dropped');

        // Dropped column on users
        $this->assertFalse(Schema::hasColumn('users', 'year'), 'users.year must be dropped');
    }

    /**
     * Test full complaint submission and workflow operates smoothly without redundant columns.
     */
    public function test_complaint_workflow_operates_without_dead_columns(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        $adviser = User::factory()->create(['department_id' => $dept->id, 'email' => 'adv.clean@uetmardan.edu.pk']);
        $adviser->assignRole('Batch Adviser');

        $coord = User::factory()->create(['department_id' => $dept->id, 'email' => 'coord.clean@uetmardan.edu.pk']);
        $coord->assignRole('Coordinator');

        $student = User::factory()->create([
            'department_id' => $dept->id,
            'adviser_id' => $adviser->id,
            'email' => 'student.clean@uetmardan.edu.pk',
        ]);
        $student->assignRole('Student');

        $category = ApplicationCategory::firstOrCreate(
            ['name' => 'Administrative'],
            ['slug' => 'administrative', 'is_active' => true]
        );

        // 1. Submit complaint
        $submitResponse = $this->actingAs($student, 'sanctum')->postJson('/api/v1/applications', [
            'title' => 'Clean Architecture Complaint',
            'description' => 'Complaint tested on modernized schema',
            'category_id' => $category->id,
            'priority' => 'medium',
        ]);

        $submitResponse->assertStatus(201)
            ->assertJsonPath('success', true);

        $appId = $submitResponse->json('data.id');

        // 2. Add remark as Adviser
        $remarkResponse = $this->actingAs($adviser, 'sanctum')->postJson("/api/v1/applications/{$appId}/remarks", [
            'remark' => 'Reviewed by Adviser and forwarding to Coordinator',
        ]);

        $remarkResponse->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.remark', 'Reviewed by Adviser and forwarding to Coordinator');

        // 3. Forward complaint to Coordinator
        $forwardResponse = $this->actingAs($adviser, 'sanctum')->putJson("/api/v1/applications/{$appId}/status", [
            'status' => 'forwarded',
            'assigned_to_id' => $coord->id,
            'notes' => 'Forwarding for coordinator approval',
        ]);

        $forwardResponse->assertStatus(200)
            ->assertJsonPath('data.status', 'forwarded');

        // 4. Resolve complaint as Coordinator
        $resolveResponse = $this->actingAs($coord, 'sanctum')->putJson("/api/v1/applications/{$appId}/status", [
            'status' => 'resolved',
            'notes' => 'Issue resolved successfully',
        ]);

        $resolveResponse->assertStatus(200)
            ->assertJsonPath('data.status', 'resolved');

        // Verify relational remarks and timeline
        $this->assertDatabaseHas('application_remarks', [
            'application_id' => $appId,
            'remark' => 'Reviewed by Adviser and forwarding to Coordinator',
        ]);
        $this->assertDatabaseHas('application_timeline', [
            'application_id' => $appId,
            'action' => 'Resolved',
        ]);
    }

    /**
     * Test notices functionality operates smoothly without notice_targets table.
     */
    public function test_notices_operate_without_notice_targets_table(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);
        $coord = User::factory()->create(['department_id' => $dept->id, 'email' => 'coord.ntclean@uetmardan.edu.pk']);
        $coord->assignRole('Coordinator');

        $student = User::factory()->create(['department_id' => $dept->id, 'email' => 'student.ntclean@uetmardan.edu.pk']);
        $student->assignRole('Student');

        // Create notice via API
        $response = $this->actingAs($coord, 'sanctum')->postJson('/api/v1/notices', [
            'title' => 'Notice on Clean Schema',
            'description' => 'Targeting handled directly via notices table',
            'tag' => 'General',
            'status' => 'published',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true);

        // Fetch notices as student
        $fetchResponse = $this->actingAs($student, 'sanctum')->getJson('/api/v1/notices');
        $fetchResponse->assertStatus(200);

        $titles = collect($fetchResponse->json('data'))->pluck('title')->toArray();
        $this->assertContains('Notice on Clean Schema', $titles);
    }

    /**
     * Test authentication operates smoothly without login_histories table.
     */
    public function test_auth_operates_without_login_histories_table(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);
        $user = User::factory()->create([
            'email' => 'clean.login@uetmardan.edu.pk',
            'password' => 'Password123!',
            'department_id' => $dept->id,
            'status' => 'approved',
        ]);
        $user->assignRole('Student');

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'clean.login@uetmardan.edu.pk',
            'password' => 'Password123!',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['token', 'user']]);
    }
}
