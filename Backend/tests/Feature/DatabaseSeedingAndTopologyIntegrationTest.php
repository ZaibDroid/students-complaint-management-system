<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\Batch;
use App\Models\Campus;
use App\Models\Department;
use App\Models\Faculty;
use App\Models\Notice;
use App\Models\Section;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DatabaseSeedingAndTopologyIntegrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_full_database_seeder_runs_end_to_end_without_errors()
    {
        $this->seed(DatabaseSeeder::class);

        // 1. Verify Topology
        $this->assertDatabaseHas('campuses', ['code' => 'MC']);
        $this->assertDatabaseHas('faculties', ['code' => 'ENG']);
        $this->assertDatabaseHas('departments', ['code' => 'CS']);

        // 2. Verify Batches have department_id set
        $dept = Department::where('code', 'CS')->first();
        $this->assertNotNull($dept);
        $this->assertDatabaseHas('batches', [
            'name' => 'Batch 2022-2026',
            'department_id' => $dept->id,
        ]);
        $this->assertDatabaseHas('batches', [
            'name' => 'Batch 2023-2027',
            'department_id' => $dept->id,
        ]);

        // 3. Verify Users with explicit registration numbers
        $this->assertDatabaseHas('users', [
            'email' => 'student@uetmardan.edu.pk',
            'registration_number' => '23MDBCS501',
            'department_id' => $dept->id,
        ]);

        $this->assertDatabaseHas('users', [
            'email' => 'coordinator@uetmardan.edu.pk',
            'registration_number' => 'FAC-CS-002',
            'department_id' => $dept->id,
        ]);

        // 4. Verify Demo Applications and Remarks
        $this->assertGreaterThanOrEqual(2, Application::count());
        $app = Application::first();
        $this->assertNotNull($app->ticket_number);
        $this->assertNotNull($app->department_id);

        // 5. Verify Demo Notices
        $this->assertGreaterThanOrEqual(2, Notice::count());
        $notice = Notice::first();
        $this->assertEquals(Notice::STATUS_PUBLISHED, $notice->status);
    }

    public function test_seeded_users_can_authenticate_and_access_scoped_data()
    {
        $this->seed(DatabaseSeeder::class);

        // 1. Student Authentication
        $loginResponse = $this->postJson('/api/v1/auth/login', [
            'email' => 'student@uetmardan.edu.pk',
            'password' => '123456',
        ]);

        $loginResponse->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.registrationNumber', '23MDBCS501')
            ->assertJsonPath('data.user.role', 'Student');

        $studentToken = $loginResponse->json('data.token');

        // 2. Student retrieves their own applications
        $studentAppsResponse = $this->withHeader('Authorization', 'Bearer ' . $studentToken)
            ->getJson('/api/v1/applications');

        $studentAppsResponse->assertStatus(200)
            ->assertJsonPath('success', true);

        // 3. Coordinator Authentication
        $coordLoginResponse = $this->postJson('/api/v1/auth/login', [
            'email' => 'coordinator@uetmardan.edu.pk',
            'password' => '123456',
        ]);

        $coordLoginResponse->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.role', 'Coordinator');

        $coordToken = $coordLoginResponse->json('data.token');

        // 4. Coordinator retrieves departmental complaints
        $coordAppsResponse = $this->withHeader('Authorization', 'Bearer ' . $coordToken)
            ->getJson('/api/v1/applications');

        $coordAppsResponse->assertStatus(200)
            ->assertJsonPath('success', true);
    }
}

