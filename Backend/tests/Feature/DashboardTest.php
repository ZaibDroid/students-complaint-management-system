<?php

namespace Tests\Feature;

use App\Models\Department;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DashboardTest extends TestCase
{
    use RefreshDatabase;

    protected User $student;
    protected User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);

        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        $this->student = User::factory()->create([
            'email' => 'student.dash@uetmardan.edu.pk',
            'department_id' => $dept->id,
            'status' => 'approved',
        ]);
        $this->student->assignRole('Student');

        $this->admin = User::factory()->create([
            'email' => 'admin.dash@uetmardan.edu.pk',
            'department_id' => $dept->id,
            'status' => 'approved',
        ]);
        $this->admin->assignRole('Admin');
    }

    public function test_student_can_fetch_dashboard(): void
    {
        $response = $this->actingAs($this->student, 'sanctum')
            ->getJson('/api/v1/dashboard');

        $response->assertStatus(200)
            ->assertJsonPath('success', true);
    }

    public function test_admin_can_fetch_dashboard_charts(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->getJson('/api/v1/dashboard/charts');

        $response->assertStatus(200)
            ->assertJsonPath('success', true);
    }
}
