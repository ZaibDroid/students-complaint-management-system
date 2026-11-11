<?php

namespace Tests\Unit;

use App\Models\Department;
use App\Models\User;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class StudentIdentityNormalizationUnitTest extends TestCase
{
    /**
     * Test User model fillable attributes include registration_number and current_semester.
     */
    public function test_user_fillable_and_casts(): void
    {
        $user = new User();

        $this->assertContains('registration_number', $user->getFillable());
        $this->assertContains('current_semester', $user->getFillable());
        $this->assertTrue($user->hasCast('current_semester', 'integer'));
    }

    /**
     * Test registration_number mutator forces uppercase and trims whitespace.
     */
    public function test_registration_number_mutator_normalizes_to_uppercase(): void
    {
        $user = new User();
        $user->registration_number = '  23mdbcs514  ';

        $this->assertEquals('23MDBCS514', $user->registration_number);
    }

    /**
     * Test registration_number accessor fallback to email prefix when attribute is empty.
     */
    public function test_registration_number_fallback_from_email(): void
    {
        $user = new User(['email' => '21cs88@uetmardan.edu.pk']);
        $this->assertEquals('21CS88', $user->registration_number);

        $emptyUser = new User();
        $this->assertEquals('N/A', $emptyUser->registration_number);
    }

    /**
     * Test current_semester mutator normalizes strings, numbers, and sem patterns.
     */
    public function test_current_semester_mutator_normalization(): void
    {
        $user = new User();

        // Direct integer
        $user->current_semester = 3;
        $this->assertEquals(3, $user->current_semester);

        // Numeric string
        $user->current_semester = '6';
        $this->assertEquals(6, $user->current_semester);

        // Natural language string: "Semester 5"
        $user->current_semester = 'Semester 5';
        $this->assertEquals(5, $user->current_semester);

        // Abbreviated string: "sem 4"
        $user->current_semester = 'sem 4';
        $this->assertEquals(4, $user->current_semester);

        // Out-of-bounds integer (> 8) should normalize to null
        $user->current_semester = 12;
        $this->assertNull($user->current_semester);

        // Invalid text should normalize to null
        $user->current_semester = 'Final Year Project';
        $this->assertNull($user->current_semester);
    }

    /**
     * Test User saving hook auto-derives registration_number and current_semester.
     */
    public function test_user_saving_hook_auto_derives_identity_fields(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        $user = User::create([
            'name' => 'Auto Identity Student',
            'email' => '23mdbcs777@uetmardan.edu.pk',
            'password' => 'Secret123!',
            'department_id' => $dept->id,
            'semester' => 'Semester 7',
        ]);

        $this->assertEquals('23MDBCS777', $user->getAttributes()['registration_number']);
        $this->assertEquals(7, $user->getAttributes()['current_semester']);
    }

    /**
     * Test scopeCrs supports both 'Class Representative' and 'CR' role names.
     */
    public function test_scope_crs_supports_both_role_conventions(): void
    {
        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        Role::firstOrCreate(['name' => 'CR', 'guard_name' => 'web']);
        Role::firstOrCreate(['name' => 'Class Representative', 'guard_name' => 'web']);
        Role::firstOrCreate(['name' => 'Student', 'guard_name' => 'web']);

        $crUser1 = User::create([
            'name' => 'CR Short Name',
            'email' => 'cr.short@uetmardan.edu.pk',
            'password' => 'Secret123!',
            'department_id' => $dept->id,
        ]);
        $crUser1->assignRole('CR');

        $crUser2 = User::create([
            'name' => 'Class Rep Full Name',
            'email' => 'cr.full@uetmardan.edu.pk',
            'password' => 'Secret123!',
            'department_id' => $dept->id,
        ]);
        $crUser2->assignRole('Class Representative');

        $regularStudent = User::create([
            'name' => 'Regular Student',
            'email' => 'regular.student@uetmardan.edu.pk',
            'password' => 'Secret123!',
            'department_id' => $dept->id,
        ]);
        $regularStudent->assignRole('Student');

        $crs = User::crs()->pluck('email')->toArray();

        $this->assertContains('cr.short@uetmardan.edu.pk', $crs);
        $this->assertContains('cr.full@uetmardan.edu.pk', $crs);
        $this->assertNotContains('regular.student@uetmardan.edu.pk', $crs);
    }
}

