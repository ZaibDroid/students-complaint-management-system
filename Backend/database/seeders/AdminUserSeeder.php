<?php

namespace Database\Seeders;

use App\Constants\RoleConstants;
use App\Models\Department;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        $department = Department::firstOrCreate(
            ['code' => 'CS'],
            ['name' => 'Department of Computer Science', 'description' => 'UET Mardan CS Department']
        );

        $passwordHash = Hash::make('123456');

        $admin = User::updateOrCreate(
            ['email' => 'admin@uetmardan.edu.pk'],
            [
                'name' => 'System Administrator',
                'registration_number' => 'ADM-SYS-001',
                'password' => $passwordHash,
                'department_id' => $department->id,
                'status' => 'approved',
            ]
        );

        $admin->syncRoles([RoleConstants::ROLE_ADMIN]);
    }
}
