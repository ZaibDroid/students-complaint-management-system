<?php

namespace Tests\Feature;

use App\Models\Department;
use App\Models\Notice;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NoticeTest extends TestCase
{
    use RefreshDatabase;

    protected User $coordinator;
    protected User $student;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);
        $this->seed(\Database\Seeders\BatchAndSectionSeeder::class);

        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        $this->coordinator = User::factory()->create([
            'email' => 'coordinator.test@uetmardan.edu.pk',
            'department_id' => $dept->id,
            'status' => 'approved',
        ]);
        $this->coordinator->assignRole('Coordinator');

        $this->student = User::factory()->create([
            'email' => 'student.notice@uetmardan.edu.pk',
            'department_id' => $dept->id,
            'status' => 'approved',
        ]);
        $this->student->assignRole('Student');
    }

    public function test_coordinator_can_create_notice(): void
    {
        $response = $this->actingAs($this->coordinator, 'sanctum')
            ->postJson('/api/v1/notices', [
                'title' => 'Exam Registration Deadline Extended',
                'description' => 'Students can register for re-appear exams until Friday.',
                'tag' => 'Academic',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.title', 'Exam Registration Deadline Extended');

        $this->assertDatabaseHas('notices', [
            'title' => 'Exam Registration Deadline Extended',
        ]);
    }

    public function test_student_can_fetch_notices(): void
    {
        Notice::create([
            'sender_id' => $this->coordinator->id,
            'title' => 'General Notice Title',
            'description' => 'General notice details content.',
            'tag' => 'General',
        ]);

        $response = $this->actingAs($this->student, 'sanctum')
            ->getJson('/api/v1/notices');

        $response->assertStatus(200)
            ->assertJsonPath('success', true);
    }
}
