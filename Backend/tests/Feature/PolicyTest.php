<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class PolicyTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        // Assuming roles are seeded or we need to create them
        Role::firstOrCreate(['name' => 'Student']);
        Role::firstOrCreate(['name' => 'Admin']);
        Role::firstOrCreate(['name' => 'Batch Adviser']);
    }

    public function test_student_can_view_own_application()
    {
        $student = User::factory()->create();
        $student->assignRole('Student');

        $application = \App\Models\Application::factory()->create([
            'student_id' => $student->id
        ]);

        $response = $this->actingAs($student)->getJson("/api/v1/applications/{$application->id}");

        $response->assertStatus(200);
    }

    public function test_student_cannot_view_others_application()
    {
        $student1 = User::factory()->create();
        $student1->assignRole('Student');

        $student2 = User::factory()->create();
        $student2->assignRole('Student');

        $application = \App\Models\Application::factory()->create([
            'student_id' => $student1->id
        ]);

        $response = $this->actingAs($student2)->getJson("/api/v1/applications/{$application->id}");

        $response->assertStatus(403);
    }
}
