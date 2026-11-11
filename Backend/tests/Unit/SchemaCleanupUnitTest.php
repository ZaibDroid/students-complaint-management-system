<?php

namespace Tests\Unit;

use App\Models\Application;
use App\Models\ApplicationRemark;
use App\Models\Department;
use App\Models\User;
use Tests\TestCase;

class SchemaCleanupUnitTest extends TestCase
{
    /**
     * Test models do not contain dropped/redundant columns in $fillable.
     */
    public function test_models_fillable_attributes_cleaned(): void
    {
        $app = new Application();
        $this->assertNotContains('attachment_path', $app->getFillable());
        $this->assertNotContains('attachment_name', $app->getFillable());
        $this->assertNotContains('attachment_type', $app->getFillable());
        $this->assertNotContains('attachment_size', $app->getFillable());
        $this->assertNotContains('admin_remarks', $app->getFillable());

        $remark = new ApplicationRemark();
        $this->assertNotContains('action_taken', $remark->getFillable());

        $user = new User();
        $this->assertNotContains('year', $user->getFillable());
    }

    /**
     * Test legacy accessors provide graceful fallbacks without schema errors.
     */
    public function test_legacy_accessors_provide_graceful_fallbacks(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        $user = new User([
            'current_semester' => 5,
        ]);
        $this->assertEquals('Semester 5', $user->year);

        $remark = new ApplicationRemark([
            'remark' => 'Official comment',
        ]);
        $this->assertNull($remark->action_taken);

        $student = User::factory()->create(['department_id' => $dept->id, 'email' => 'unit.clean@uetmardan.edu.pk']);
        $application = Application::create([
            'student_id' => $student->id,
            'department_id' => $dept->id,
            'title' => 'Test App For Remarks Fallback',
            'description' => 'Testing remark accessor',
            'status' => 'pending',
        ]);

        ApplicationRemark::create([
            'application_id' => $application->id,
            'user_id' => $student->id,
            'remark' => 'Latest review note',
        ]);

        $this->assertEquals('Latest review note', $application->admin_remarks);
    }
}

