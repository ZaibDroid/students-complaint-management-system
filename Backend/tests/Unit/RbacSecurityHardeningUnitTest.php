<?php

namespace Tests\Unit;

use App\Models\Campus;
use App\Models\Department;
use App\Models\Faculty;
use App\Models\User;
use App\Policies\UserPolicy;
use App\Services\AuthService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RbacSecurityHardeningUnitTest extends TestCase
{
    use RefreshDatabase;

    protected Department $dept1;
    protected Department $dept2;
    protected UserPolicy $policy;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);

        $campus = Campus::create(['name' => 'Main Campus', 'code' => 'MC']);
        $faculty = Faculty::create(['campus_id' => $campus->id, 'name' => 'Engineering', 'code' => 'ENG']);
        $this->dept1 = Department::create(['faculty_id' => $faculty->id, 'name' => 'Computer Science', 'code' => 'CS']);
        $this->dept2 = Department::create(['faculty_id' => $faculty->id, 'name' => 'Electrical Engineering', 'code' => 'EE']);

        $this->policy = new UserPolicy();
    }

    public function test_user_policy_enforces_strict_department_matching_for_update_staff()
    {
        $chairmanDept1 = User::factory()->create(['department_id' => $this->dept1->id]);
        $chairmanDept1->assignRole('Chairman');

        $coordinatorDept1 = User::factory()->create(['department_id' => $this->dept1->id]);
        $coordinatorDept1->assignRole('Coordinator');

        $coordinatorDept2 = User::factory()->create(['department_id' => $this->dept2->id]);
        $coordinatorDept2->assignRole('Coordinator');

        $adviserDept1 = User::factory()->create(['department_id' => $this->dept1->id]);
        $adviserDept1->assignRole('Batch Adviser');

        $adviserDept2 = User::factory()->create(['department_id' => $this->dept2->id]);
        $adviserDept2->assignRole('Batch Adviser');

        // Chairman in Dept 1 CAN update Coordinator in Dept 1
        $this->assertTrue($this->policy->updateStaff($chairmanDept1, $coordinatorDept1));

        // Chairman in Dept 1 CANNOT update Coordinator in Dept 2 (cross-department breach)
        $this->assertFalse($this->policy->updateStaff($chairmanDept1, $coordinatorDept2));

        // Coordinator in Dept 1 CAN update Adviser in Dept 1
        $this->assertTrue($this->policy->updateStaff($coordinatorDept1, $adviserDept1));

        // Coordinator in Dept 1 CANNOT update Adviser in Dept 2 (cross-department breach)
        $this->assertFalse($this->policy->updateStaff($coordinatorDept1, $adviserDept2));

        // Coordinator CANNOT update peer Coordinator in same department
        $peerCoordinator = User::factory()->create(['department_id' => $this->dept1->id]);
        $peerCoordinator->assignRole('Coordinator');
        $this->assertFalse($this->policy->updateStaff($coordinatorDept1, $peerCoordinator));

        // Users without department cannot manage staff
        $unassignedChairman = User::factory()->create(['department_id' => null]);
        $unassignedChairman->assignRole('Chairman');
        $this->assertFalse($this->policy->updateStaff($unassignedChairman, $adviserDept1));
    }

    public function test_user_policy_enforces_strict_department_matching_and_self_deletion_protection_for_delete_staff()
    {
        $coordinator = User::factory()->create(['department_id' => $this->dept1->id]);
        $coordinator->assignRole('Coordinator');

        $adviserSameDept = User::factory()->create(['department_id' => $this->dept1->id]);
        $adviserSameDept->assignRole('Batch Adviser');

        $adviserOtherDept = User::factory()->create(['department_id' => $this->dept2->id]);
        $adviserOtherDept->assignRole('Batch Adviser');

        // Cannot delete self
        $this->assertFalse($this->policy->deleteStaff($coordinator, $coordinator));

        // Cannot delete adviser in different department
        $this->assertFalse($this->policy->deleteStaff($coordinator, $adviserOtherDept));

        // Can delete adviser in same department
        $this->assertTrue($this->policy->deleteStaff($coordinator, $adviserSameDept));
    }

    public function test_auth_service_register_student_unconditionally_forces_is_cr_to_false()
    {
        /** @var AuthService $authService */
        $authService = app(AuthService::class);

        $payload = [
            'name' => 'Malicious Student',
            'email' => '23mdbcs999@uetmardan.edu.pk',
            'password' => 'Secret123!',
            'department_id' => $this->dept1->id,
            'is_cr' => true,
            'isCR' => true,
            'role' => 'Admin',
        ];

        $result = $authService->registerStudent($payload);
        $user = $result['user'];

        $this->assertFalse((bool)$user->is_cr);
        $this->assertFalse($user->hasRole('Admin'));
        $this->assertTrue($user->hasRole('Student'));
    }
}

