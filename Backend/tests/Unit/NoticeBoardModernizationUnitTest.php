<?php

namespace Tests\Unit;

use App\Models\Batch;
use App\Models\Department;
use App\Models\Notice;
use App\Models\Section;
use App\Models\User;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Tests\TestCase;

class NoticeBoardModernizationUnitTest extends TestCase
{
    /**
     * Test Notice model fillable attributes, casting, and relationships.
     */
    public function test_notice_model_attributes_and_relationships(): void
    {
        $notice = new Notice();

        $this->assertContains('department_id', $notice->getFillable());
        $this->assertContains('target_batch_id', $notice->getFillable());
        $this->assertContains('target_section_id', $notice->getFillable());
        $this->assertContains('target_role', $notice->getFillable());

        // Casts
        $this->assertTrue($notice->hasCast('published_at', 'datetime'));
        $this->assertTrue($notice->hasCast('scheduled_at', 'datetime'));
        $this->assertTrue($notice->hasCast('expires_at', 'datetime'));

        // Relation: Notice belongsTo Department
        $deptRel = $notice->department();
        $this->assertInstanceOf(BelongsTo::class, $deptRel);
        $this->assertInstanceOf(Department::class, $deptRel->getRelated());
        $this->assertEquals('department_id', $deptRel->getForeignKeyName());

        // Relation: Notice belongsTo targetBatch
        $batchRel = $notice->targetBatch();
        $this->assertInstanceOf(BelongsTo::class, $batchRel);
        $this->assertInstanceOf(Batch::class, $batchRel->getRelated());
        $this->assertEquals('target_batch_id', $batchRel->getForeignKeyName());

        // Relation: Notice belongsTo targetSection
        $secRel = $notice->targetSection();
        $this->assertInstanceOf(BelongsTo::class, $secRel);
        $this->assertInstanceOf(Section::class, $secRel->getRelated());
        $this->assertEquals('target_section_id', $secRel->getForeignKeyName());

        // Relation: Notice belongsTo sender
        $senderRel = $notice->sender();
        $this->assertInstanceOf(BelongsTo::class, $senderRel);
        $this->assertInstanceOf(User::class, $senderRel->getRelated());
        $this->assertEquals('sender_id', $senderRel->getForeignKeyName());
    }

    /**
     * Test Notice model automatically derives department_id from sender on creation.
     */
    public function test_notice_auto_derives_department_id_from_sender(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        $sender = User::factory()->create([
            'department_id' => $dept->id,
            'email' => 'sender.autodept@uetmardan.edu.pk',
        ]);

        $notice = Notice::create([
            'sender_id' => $sender->id,
            'title' => 'Auto Department Notice',
            'description' => 'Testing automatic department resolution for notice',
        ]);

        $this->assertNotNull($notice->department_id);
        $this->assertEquals($dept->id, $notice->department_id);
        $this->assertEquals($dept->id, $notice->department->id);
    }

    /**
     * Test Notice query scopes for department and published status.
     */
    public function test_notice_scopes(): void
    {
        $deptCS = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);
        $deptEE = Department::firstOrCreate(['code' => 'EE'], ['name' => 'Electrical Engineering']);

        $senderCS = User::factory()->create(['department_id' => $deptCS->id, 'email' => 'notice.cs@uetmardan.edu.pk']);

        $noticeCS = Notice::create([
            'sender_id' => $senderCS->id,
            'department_id' => $deptCS->id,
            'title' => 'CS Notice',
            'description' => 'CS Description',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        $noticeGlobal = Notice::create([
            'sender_id' => $senderCS->id,
            'department_id' => null,
            'title' => 'Global Notice',
            'description' => 'Global Description',
            'status' => Notice::STATUS_PUBLISHED,
        ]);

        $noticeDraft = Notice::create([
            'sender_id' => $senderCS->id,
            'department_id' => $deptCS->id,
            'title' => 'Draft Notice',
            'description' => 'Draft Description',
            'status' => Notice::STATUS_DRAFT,
        ]);

        // Published scope should exclude draft
        $published = Notice::published()->pluck('id')->toArray();
        $this->assertContains($noticeCS->id, $published);
        $this->assertContains($noticeGlobal->id, $published);
        $this->assertNotContains($noticeDraft->id, $published);

        // forDepartment scope should return CS + Global, but not other departments
        $forCS = Notice::forDepartment($deptCS->id)->pluck('id')->toArray();
        $this->assertContains($noticeCS->id, $forCS);
        $this->assertContains($noticeGlobal->id, $forCS);

        $forEE = Notice::forDepartment($deptEE->id)->pluck('id')->toArray();
        $this->assertNotContains($noticeCS->id, $forEE);
        $this->assertContains($noticeGlobal->id, $forEE);
    }
}

