<?php

namespace Tests\Feature;

use App\Models\Department;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);
    }

    public function test_student_can_register_with_valid_university_email()
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Test Student',
            'email' => '2022cs99@uetmardan.edu.pk',
            'password' => 'Password123!',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['user', 'token']]);
    }

    public function test_student_cannot_register_with_non_university_email()
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Invalid Student',
            'email' => 'test@gmail.com',
            'password' => 'Password123!',
        ]);

        $response->assertStatus(422)
            ->assertJsonPath('success', false);
    }

    public function test_student_can_update_batch_and_section_profile()
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        $student = User::factory()->create([
            'email' => '23mdbcs495@uetmardan.edu.pk',
            'department_id' => $dept->id,
            'status' => 'approved',
        ]);
        $student->assignRole('Student');

        $response = $this->actingAs($student, 'sanctum')
            ->putJson('/api/v1/auth/profile', [
                'name' => 'Amin khan',
                'year' => 'Semester 7',
                'batch' => '2023',
                'section' => 'A',
                'phone' => '03118036997',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.section', 'A')
            ->assertJsonPath('data.batch', '2023');

        $this->assertDatabaseHas('sections', [
            'name' => 'A',
        ]);
    }
}
