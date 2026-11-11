<?php

namespace Tests\Feature;

use App\Auth\Services\AuthService as AuthHelperService;
use App\Models\Department;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class StudentIdentityNormalizationIntegrationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test schema integrity for Prompt 2 normalized columns.
     */
    public function test_users_table_has_normalized_identity_columns(): void
    {
        $this->assertTrue(Schema::hasColumn('users', 'registration_number'), 'users table must have registration_number column');
        $this->assertTrue(Schema::hasColumn('users', 'current_semester'), 'users table must have current_semester column');
    }

    /**
     * Test data migration script logic backfilling existing records.
     */
    public function test_data_migration_backfills_registration_number_and_current_semester(): void
    {
        if (!Schema::hasColumn('users', 'year')) {
            $this->markTestSkipped('Legacy users.year column has been pruned by Prompt 5 cleanup.');
        }

        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        // Insert directly into DB bypassing Eloquent hooks to simulate pre-migration state
        $userId1 = DB::table('users')->insertGetId([
            'name' => 'Legacy Student One',
            'email' => '23mdbcs514@uetmardan.edu.pk',
            'password' => Hash::make('Secret123!'),
            'department_id' => $dept->id,
            'semester' => 'Semester 4',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $userId2 = DB::table('users')->insertGetId([
            'name' => 'Legacy Student Two',
            'email' => '22ee102@uetmardan.edu.pk',
            'password' => Hash::make('Secret123!'),
            'department_id' => $dept->id,
            'year' => 'Semester 6',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $userId3 = DB::table('users')->insertGetId([
            'name' => 'Legacy Student Three',
            'email' => '21cs99@uetmardan.edu.pk',
            'password' => Hash::make('Secret123!'),
            'department_id' => $dept->id,
            'semester' => '3',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Run backfill routines as defined in migration 000002
        $users = DB::table('users')->whereNull('registration_number')->whereNotNull('email')->get();
        foreach ($users as $u) {
            if (str_contains($u->email, '@')) {
                $derivedRegNo = strtoupper(trim(explode('@', $u->email)[0]));
                if (!empty($derivedRegNo)) {
                    $exists = DB::table('users')->where('registration_number', $derivedRegNo)->where('id', '!=', $u->id)->exists();
                    if (!$exists) {
                        DB::table('users')->where('id', $u->id)->update([
                            'registration_number' => $derivedRegNo,
                        ]);
                    }
                }
            }
        }

        $usersToUpdate = DB::table('users')->whereNull('current_semester')->get();
        foreach ($usersToUpdate as $u) {
            $sem = null;
            if (!empty($u->semester) && is_numeric(trim($u->semester))) {
                $sem = (int) trim($u->semester);
            } elseif (!empty($u->semester) && preg_match('/(?:semester|sem)\s*(\d+)/i', $u->semester, $matches)) {
                $sem = (int) $matches[1];
            } elseif (!empty($u->year) && preg_match('/(?:semester|sem)\s*(\d+)/i', $u->year, $matches)) {
                $sem = (int) $matches[1];
            }

            if ($sem !== null && $sem >= 1 && $sem <= 8) {
                DB::table('users')->where('id', $u->id)->update([
                    'current_semester' => $sem,
                ]);
            }
        }

        // Verify backfill accuracy
        $u1 = DB::table('users')->find($userId1);
        $this->assertEquals('23MDBCS514', $u1->registration_number);
        $this->assertEquals(4, $u1->current_semester);

        $u2 = DB::table('users')->find($userId2);
        $this->assertEquals('22EE102', $u2->registration_number);
        $this->assertEquals(6, $u2->current_semester);

        $u3 = DB::table('users')->find($userId3);
        $this->assertEquals('21CS99', $u3->registration_number);
        $this->assertEquals(3, $u3->current_semester);
    }

    /**
     * Test student registration API automatically populates registration_number and current_semester.
     */
    public function test_student_registration_api_normalizes_identity(): void
    {
        Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Registration Test Student',
            'email' => '24mdbcs201@uetmardan.edu.pk',
            'password' => 'Password123!',
            'semester' => 'Semester 2',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.registration_number', '24MDBCS201')
            ->assertJsonPath('data.user.current_semester', 2);

        $this->assertDatabaseHas('users', [
            'email' => '24mdbcs201@uetmardan.edu.pk',
            'registration_number' => '24MDBCS201',
            'current_semester' => 2,
        ]);
    }

    /**
     * Test student authentication using registration_number directly.
     */
    public function test_student_can_authenticate_via_registration_number(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        $user = User::create([
            'name' => 'Login Via RegNo Student',
            'email' => '23mdbcs888@uetmardan.edu.pk',
            'registration_number' => '23MDBCS888',
            'password' => 'SecurePass123!',
            'department_id' => $dept->id,
            'status' => 'approved',
        ]);
        $user->assignRole('Student');

        $authHelper = app(AuthHelperService::class);

        // Authenticate using exact uppercase registration number
        $authenticatedUser = $authHelper->validateCredentials('23MDBCS888', 'SecurePass123!');
        $this->assertNotNull($authenticatedUser);
        $this->assertEquals($user->id, $authenticatedUser->id);

        // Authenticate using lowercase registration number
        $authenticatedUserLower = $authHelper->validateCredentials('23mdbcs888', 'SecurePass123!');
        $this->assertNotNull($authenticatedUserLower);
        $this->assertEquals($user->id, $authenticatedUserLower->id);

        // Authenticate using standard email
        $authenticatedUserEmail = $authHelper->validateCredentials('23mdbcs888@uetmardan.edu.pk', 'SecurePass123!');
        $this->assertNotNull($authenticatedUserEmail);
        $this->assertEquals($user->id, $authenticatedUserEmail->id);
    }

    /**
     * Test database enforces unique registration_number constraint.
     */
    public function test_unique_registration_number_constraint_is_enforced(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        User::create([
            'name' => 'Student Unique A',
            'email' => 'first.user@uetmardan.edu.pk',
            'registration_number' => 'REG12345',
            'password' => 'Password123!',
            'department_id' => $dept->id,
        ]);

        $this->expectException(QueryException::class);

        // Attempt duplicate registration number directly on database
        DB::table('users')->insert([
            'name' => 'Student Unique B',
            'email' => 'second.user@uetmardan.edu.pk',
            'registration_number' => 'REG12345',
            'password' => Hash::make('Password123!'),
            'department_id' => $dept->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    /**
     * Test scopeCrs retrieves both 'CR' and 'Class Representative' users.
     */
    public function test_scope_crs_integration_with_roles(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        Role::firstOrCreate(['name' => 'CR', 'guard_name' => 'web']);
        Role::firstOrCreate(['name' => 'Class Representative', 'guard_name' => 'web']);
        Role::firstOrCreate(['name' => 'Student', 'guard_name' => 'web']);

        $cr1 = User::create([
            'name' => 'CR One',
            'email' => 'cr1@uetmardan.edu.pk',
            'password' => 'Password123!',
            'department_id' => $dept->id,
        ]);
        $cr1->assignRole('CR');

        $cr2 = User::create([
            'name' => 'CR Two',
            'email' => 'cr2@uetmardan.edu.pk',
            'password' => 'Password123!',
            'department_id' => $dept->id,
        ]);
        $cr2->assignRole('Class Representative');

        $student = User::create([
            'name' => 'Regular Student',
            'email' => 'student@uetmardan.edu.pk',
            'password' => 'Password123!',
            'department_id' => $dept->id,
        ]);
        $student->assignRole('Student');

        $crs = User::crs()->get();

        $this->assertCount(2, $crs);
        $this->assertTrue($crs->contains('id', $cr1->id));
        $this->assertTrue($crs->contains('id', $cr2->id));
        $this->assertFalse($crs->contains('id', $student->id));
    }
}

