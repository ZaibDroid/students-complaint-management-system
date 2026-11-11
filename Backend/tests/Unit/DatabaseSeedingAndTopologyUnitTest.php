<?php

namespace Tests\Unit;

use App\Models\Batch;
use App\Models\Campus;
use App\Models\Department;
use App\Models\Faculty;
use App\Models\User;
use Database\Seeders\AdminUserSeeder;
use Database\Seeders\BatchAndSectionSeeder;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DatabaseSeedingAndTopologyUnitTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);
    }

    public function test_batch_and_section_seeder_associates_all_batches_with_department_id()
    {
        $this->seed(BatchAndSectionSeeder::class);

        // 1. Verify Campus, Faculty, Department topology
        $campus = Campus::where('code', 'MC')->first();
        $this->assertNotNull($campus);

        $faculty = Faculty::where('code', 'ENG')->first();
        $this->assertNotNull($faculty);
        $this->assertEquals($campus->id, $faculty->campus_id);

        $dept = Department::where('code', 'CS')->first();
        $this->assertNotNull($dept);
        $this->assertEquals($faculty->id, $dept->faculty_id);

        // 2. Verify all Batches have department_id set to the CS department
        $batches = Batch::with(['department', 'sections'])->get();
        $this->assertGreaterThanOrEqual(4, $batches->count());

        foreach ($batches as $batch) {
            $this->assertNotNull($batch->department_id);
            $this->assertEquals($dept->id, $batch->department_id);
            $this->assertEquals('Department of Computer Science', $batch->department->name);
            $this->assertGreaterThanOrEqual(3, $batch->sections->count());
        }
    }

    public function test_admin_user_seeder_seeds_explicit_registration_numbers()
    {
        $this->seed(BatchAndSectionSeeder::class);
        $this->seed(AdminUserSeeder::class);

        // 1. Student has explicit registration number and semester
        $student = User::where('email', 'student@uetmardan.edu.pk')->first();
        $this->assertNotNull($student);
        $this->assertEquals('23MDBCS501', $student->registration_number);
        $this->assertEquals(4, $student->current_semester);
        $this->assertTrue($student->hasRole('Student'));

        // 2. Staff members have explicit institutional registration numbers
        $adviser = User::where('email', 'adviser@uetmardan.edu.pk')->first();
        $this->assertNotNull($adviser);
        $this->assertEquals('FAC-CS-001', $adviser->registration_number);

        $coordinator = User::where('email', 'coordinator@uetmardan.edu.pk')->first();
        $this->assertNotNull($coordinator);
        $this->assertEquals('FAC-CS-002', $coordinator->registration_number);

        $chairman = User::where('email', 'chairman@uetmardan.edu.pk')->first();
        $this->assertNotNull($chairman);
        $this->assertEquals('FAC-CS-003', $chairman->registration_number);

        $admin = User::where('email', 'admin@uetmardan.edu.pk')->first();
        $this->assertNotNull($admin);
        $this->assertEquals('ADM-SYS-001', $admin->registration_number);
    }
}

