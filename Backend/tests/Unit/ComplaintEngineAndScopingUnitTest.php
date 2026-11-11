<?php

namespace Tests\Unit;

use App\Models\Application;
use App\Models\ApplicationAttachment;
use App\Models\ApplicationRemark;
use App\Models\ApplicationTimeline;
use App\Models\Department;
use App\Models\User;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Tests\TestCase;

class ComplaintEngineAndScopingUnitTest extends TestCase
{
    /**
     * Test Application model fillable attributes, casting, and relationships.
     */
    public function test_application_model_attributes_and_relationships(): void
    {
        $application = new Application();

        $this->assertContains('department_id', $application->getFillable());
        $this->assertContains('ticket_number', $application->getFillable());
        $this->assertContains('student_id', $application->getFillable());

        // Relationship: Application belongsTo Department
        $deptRelation = $application->department();
        $this->assertInstanceOf(BelongsTo::class, $deptRelation);
        $this->assertInstanceOf(Department::class, $deptRelation->getRelated());
        $this->assertEquals('department_id', $deptRelation->getForeignKeyName());

        // Relationship: Application hasMany ApplicationAttachment
        $attRelation = $application->attachments();
        $this->assertInstanceOf(HasMany::class, $attRelation);
        $this->assertInstanceOf(ApplicationAttachment::class, $attRelation->getRelated());
        $this->assertEquals('application_id', $attRelation->getForeignKeyName());

        // Relationship: Application hasMany ApplicationRemark
        $remarksRelation = $application->remarks();
        $this->assertInstanceOf(HasMany::class, $remarksRelation);
        $this->assertInstanceOf(ApplicationRemark::class, $remarksRelation->getRelated());

        // Relationship: Application hasMany ApplicationTimeline
        $timelineRelation = $application->timeline();
        $this->assertInstanceOf(HasMany::class, $timelineRelation);
        $this->assertInstanceOf(ApplicationTimeline::class, $timelineRelation->getRelated());
    }

    /**
     * Test ApplicationAttachment model fillable attributes, casts, and url accessor.
     */
    public function test_application_attachment_model_attributes_and_accessors(): void
    {
        $attachment = new ApplicationAttachment([
            'application_id' => 1,
            'file_name' => 'receipt.pdf',
            'file_path' => 'Applications/1/receipt.pdf',
            'file_type' => 'application/pdf',
            'file_size' => 1024,
        ]);

        $this->assertEquals([
            'application_id',
            'file_name',
            'file_path',
            'file_type',
            'file_size',
        ], $attachment->getFillable());

        $this->assertTrue($attachment->hasCast('file_size', 'integer'));

        // Belongs to Application
        $appRelation = $attachment->application();
        $this->assertInstanceOf(BelongsTo::class, $appRelation);
        $this->assertInstanceOf(Application::class, $appRelation->getRelated());

        // URL Accessor
        $this->assertStringContainsString('storage/Applications/1/receipt.pdf', $attachment->url);

        // Absolute URL pass-through
        $externalAttachment = new ApplicationAttachment(['file_path' => 'https://cdn.example.com/file.png']);
        $this->assertEquals('https://cdn.example.com/file.png', $externalAttachment->url);
    }

    /**
     * Test Application model auto-derives department_id from student on creation.
     */
    public function test_application_auto_derives_department_id_from_student(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        $student = User::factory()->create([
            'department_id' => $dept->id,
            'email' => 'student.autodept@uetmardan.edu.pk',
        ]);

        $app = Application::create([
            'student_id' => $student->id,
            'title' => 'Auto Department App',
            'description' => 'Testing automatic department linking',
            'status' => 'pending',
            'priority' => 'medium',
        ]);

        $this->assertNotNull($app->department_id);
        $this->assertEquals($dept->id, $app->department_id);
        $this->assertEquals($dept->id, $app->department->id);
    }

    /**
     * Test scopeForDepartment query scope filters applications by department_id.
     */
    public function test_scope_for_department(): void
    {
        $deptCS = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);
        $deptEE = Department::firstOrCreate(['code' => 'EE'], ['name' => 'Electrical Engineering']);

        $studentCS = User::factory()->create(['department_id' => $deptCS->id, 'email' => 'cs.scope@uetmardan.edu.pk']);
        $studentEE = User::factory()->create(['department_id' => $deptEE->id, 'email' => 'ee.scope@uetmardan.edu.pk']);

        $appCS = Application::create([
            'student_id' => $studentCS->id,
            'department_id' => $deptCS->id,
            'title' => 'CS Application',
            'description' => 'CS Description',
            'status' => 'pending',
        ]);

        $appEE = Application::create([
            'student_id' => $studentEE->id,
            'department_id' => $deptEE->id,
            'title' => 'EE Application',
            'description' => 'EE Description',
            'status' => 'pending',
        ]);

        $csApps = Application::forDepartment($deptCS->id)->pluck('id')->toArray();
        $this->assertContains($appCS->id, $csApps);
        $this->assertNotContains($appEE->id, $csApps);
    }
}

