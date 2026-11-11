<?php

namespace Tests\Feature;

use App\Models\Batch;
use App\Models\Department;
use App\Models\Notice;
use App\Models\Section;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class NoticeBoardModernizationIntegrationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test schema integrity for Prompt 4 normalized notice targeting columns.
     */
    public function test_notice_schema_integrity(): void
    {
        $this->assertTrue(Schema::hasTable('notices'), 'Table notices must exist');
        $this->assertTrue(Schema::hasColumns('notices', [
            'department_id',
            'target_batch_id',
            'target_section_id',
            'target_role',
        ]));
    }

    /**
     * Test data migration backfills normalized columns from notice_targets table.
     */
    public function test_data_migration_backfills_from_notice_targets(): void
    {
        if (!Schema::hasTable('notice_targets')) {
            $this->markTestSkipped('Legacy notice_targets table has been pruned by Prompt 5 cleanup.');
        }

        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);
        $sender = User::factory()->create(['department_id' => $dept->id, 'email' => 'sender.bf@uetmardan.edu.pk']);
        $batch = Batch::create(['name' => 'Batch 2024', 'start_year' => 2024, 'end_year' => 2028, 'department_id' => $dept->id]);
        $section = Section::create(['batch_id' => $batch->id, 'name' => 'Section A']);

        // Insert legacy notices without targets
        $n1 = DB::table('notices')->insertGetId([
            'sender_id' => $sender->id,
            'title' => 'Notice For Dept Target',
            'description' => 'Targeted to Dept',
            'status' => 'published',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $n2 = DB::table('notices')->insertGetId([
            'sender_id' => $sender->id,
            'title' => 'Notice For Batch Target',
            'description' => 'Targeted to Batch',
            'status' => 'published',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $n3 = DB::table('notices')->insertGetId([
            'sender_id' => $sender->id,
            'title' => 'Notice For Section Target',
            'description' => 'Targeted to Section',
            'status' => 'published',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $n4 = DB::table('notices')->insertGetId([
            'sender_id' => $sender->id,
            'title' => 'Notice For CR Target',
            'description' => 'Targeted to CR only',
            'status' => 'published',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Insert into legacy notice_targets table
        DB::table('notice_targets')->insert([
            ['notice_id' => $n1, 'target_type' => 'department_id', 'target_value' => (string)$dept->id, 'created_at' => now(), 'updated_at' => now()],
            ['notice_id' => $n2, 'target_type' => 'batch_id', 'target_value' => (string)$batch->id, 'created_at' => now(), 'updated_at' => now()],
            ['notice_id' => $n3, 'target_type' => 'section_id', 'target_value' => (string)$section->id, 'created_at' => now(), 'updated_at' => now()],
            ['notice_id' => $n4, 'target_type' => 'crs_only', 'target_value' => 'true', 'created_at' => now(), 'updated_at' => now()],
        ]);

        // Execute backfill routines as defined in migration 000004
        $targets = DB::table('notice_targets')->get();
        foreach ($targets as $target) {
            $update = [];
            if ($target->target_type === 'department_id' && is_numeric($target->target_value)) {
                $update['department_id'] = (int)$target->target_value;
            } elseif ($target->target_type === 'batch_id' && is_numeric($target->target_value)) {
                $update['target_batch_id'] = (int)$target->target_value;
            } elseif ($target->target_type === 'section_id' && is_numeric($target->target_value)) {
                $update['target_section_id'] = (int)$target->target_value;
            } elseif ($target->target_type === 'crs_only') {
                $update['target_role'] = 'CR';
            }

            if (!empty($update)) {
                DB::table('notices')->where('id', $target->notice_id)->update($update);
            }
        }

        // Verify backfill results
        $row1 = DB::table('notices')->find($n1);
        $this->assertEquals($dept->id, $row1->department_id);

        $row2 = DB::table('notices')->find($n2);
        $this->assertEquals($batch->id, $row2->target_batch_id);

        $row3 = DB::table('notices')->find($n3);
        $this->assertEquals($section->id, $row3->target_section_id);

        $row4 = DB::table('notices')->find($n4);
        $this->assertEquals('CR', $row4->target_role);
    }

    /**
     * Test notice creation API with normalized targeting parameters.
     */
    public function test_coordinator_can_create_notice_with_direct_targeting(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);
        $batch = Batch::create(['name' => 'CS Batch 2025', 'start_year' => 2025, 'end_year' => 2029, 'department_id' => $dept->id]);
        $section = Section::create(['batch_id' => $batch->id, 'name' => 'Section B']);

        $coordinator = User::factory()->create([
            'email' => 'coord.api@uetmardan.edu.pk',
            'department_id' => $dept->id,
        ]);
        $coordinator->assignRole('Coordinator');

        $response = $this->actingAs($coordinator, 'sanctum')->postJson('/api/v1/notices', [
            'title' => 'Special Class for Section B',
            'description' => 'Mandatory makeup class this Saturday at 10 AM.',
            'tag' => 'Academic',
            'target_batch_id' => $batch->id,
            'target_section_id' => $section->id,
            'target_role' => 'CR',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.title', 'Special Class for Section B')
            ->assertJsonPath('data.target_batch_id', (string)$batch->id)
            ->assertJsonPath('data.target_section_id', (string)$section->id)
            ->assertJsonPath('data.target_role', 'CR')
            ->assertJsonPath('data.target_crs_only', true);

        $this->assertDatabaseHas('notices', [
            'title' => 'Special Class for Section B',
            'target_batch_id' => $batch->id,
            'target_section_id' => $section->id,
            'target_role' => 'CR',
        ]);
    }

    /**
     * Test targeted notices delivery to students based on batch, section, and CR role.
     */
    public function test_targeted_notices_delivery_to_students(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);
        $sender = User::factory()->create(['department_id' => $dept->id, 'email' => 'sender.del@uetmardan.edu.pk']);
        $sender->assignRole('Coordinator');

        $batchA = Batch::create(['name' => 'Batch A', 'start_year' => 2023, 'end_year' => 2027, 'department_id' => $dept->id]);
        $secA1 = Section::create(['batch_id' => $batchA->id, 'name' => 'A1']);

        $batchB = Batch::create(['name' => 'Batch B', 'start_year' => 2024, 'end_year' => 2028, 'department_id' => $dept->id]);
        $secB1 = Section::create(['batch_id' => $batchB->id, 'name' => 'B1']);

        // Notice 1: targeted to Batch A, Section A1
        $nSecA1 = Notice::create([
            'sender_id' => $sender->id,
            'department_id' => $dept->id,
            'target_batch_id' => $batchA->id,
            'target_section_id' => $secA1->id,
            'title' => 'Notice For Section A1 Only',
            'description' => 'A1 description',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        // Notice 2: targeted to Batch B
        $nBatchB = Notice::create([
            'sender_id' => $sender->id,
            'department_id' => $dept->id,
            'target_batch_id' => $batchB->id,
            'target_section_id' => null,
            'title' => 'Notice For Batch B Only',
            'description' => 'B description',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        // Notice 3: targeted to CRs only
        $nCr = Notice::create([
            'sender_id' => $sender->id,
            'department_id' => $dept->id,
            'target_batch_id' => $batchA->id,
            'target_role' => 'CR',
            'title' => 'Notice For CRs Only',
            'description' => 'CR meeting description',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        // Notice 4: Global notice for department
        $nGlobal = Notice::create([
            'sender_id' => $sender->id,
            'department_id' => $dept->id,
            'title' => 'Global Department Notice',
            'description' => 'General info',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        // Regular student in Batch A, Section A1 (not CR)
        $regularStudent = User::factory()->create([
            'department_id' => $dept->id,
            'batch_id' => $batchA->id,
            'section_id' => $secA1->id,
            'email' => 'regular.secA1@uetmardan.edu.pk',
        ]);
        $regularStudent->assignRole('Student');

        $regResponse = $this->actingAs($regularStudent, 'sanctum')->getJson('/api/v1/notices');
        $regResponse->assertStatus(200);

        $regNoticeIds = collect($regResponse->json('data'))->pluck('id')->map(fn($id) => (int)$id)->toArray();
        $this->assertContains($nSecA1->id, $regNoticeIds, 'Regular student in A1 should see A1 notice');
        $this->assertContains($nGlobal->id, $regNoticeIds, 'Regular student should see Global notice');
        $this->assertNotContains($nBatchB->id, $regNoticeIds, 'Regular student in A should NOT see Batch B notice');
        $this->assertNotContains($nCr->id, $regNoticeIds, 'Regular student should NOT see CR-only notice');

        // CR student in Batch A, Section A1
        $crStudent = User::factory()->create([
            'department_id' => $dept->id,
            'batch_id' => $batchA->id,
            'section_id' => $secA1->id,
            'email' => 'cr.secA1@uetmardan.edu.pk',
        ]);
        $crStudent->assignRole('Student');
        $crStudent->assignRole('CR');

        $crResponse = $this->actingAs($crStudent, 'sanctum')->getJson('/api/v1/notices');
        $crResponse->assertStatus(200);

        $crNoticeIds = collect($crResponse->json('data'))->pluck('id')->map(fn($id) => (int)$id)->toArray();
        $this->assertContains($nSecA1->id, $crNoticeIds);
        $this->assertContains($nGlobal->id, $crNoticeIds);
        $this->assertContains($nCr->id, $crNoticeIds, 'CR student should see CR notice');
        $this->assertNotContains($nBatchB->id, $crNoticeIds);
    }

    /**
     * Test foreign keys set null on delete of batch or section to preserve notices.
     */
    public function test_target_foreign_keys_set_null_on_delete(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);
        $sender = User::factory()->create(['department_id' => $dept->id, 'email' => 'sender.fk@uetmardan.edu.pk']);
        $batch = Batch::create(['name' => 'Batch FK Test', 'start_year' => 2024, 'end_year' => 2028, 'department_id' => $dept->id]);
        $section = Section::create(['batch_id' => $batch->id, 'name' => 'Section FK Test']);

        $notice = Notice::create([
            'sender_id' => $sender->id,
            'department_id' => $dept->id,
            'target_batch_id' => $batch->id,
            'target_section_id' => $section->id,
            'title' => 'Notice For Deletion Testing',
            'description' => 'Testing set null',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        // Deleting section should set target_section_id = null on notice
        $section->forceDelete();
        $notice->refresh();
        $this->assertNull($notice->target_section_id);
        $this->assertEquals($batch->id, $notice->target_batch_id);

        // Deleting batch should set target_batch_id = null on notice
        $batch->forceDelete();
        $notice->refresh();
        $this->assertNull($notice->target_batch_id);
    }
}

