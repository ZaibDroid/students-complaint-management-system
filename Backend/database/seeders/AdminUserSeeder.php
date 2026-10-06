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

        $users = [
            [
                'name' => 'Test Student',
                'email' => 'student@uetmardan.edu.pk',
                'role' => RoleConstants::ROLE_STUDENT,
            ],
            [
                'name' => 'Batch Adviser',
                'email' => 'adviser@uetmardan.edu.pk',
                'role' => RoleConstants::ROLE_ADVISER,
            ],
            [
                'name' => 'Department Coordinator',
                'email' => 'coordinator@uetmardan.edu.pk',
                'role' => RoleConstants::ROLE_COORDINATOR,
            ],
            [
                'name' => 'Department Chairman',
                'email' => 'chairman@uetmardan.edu.pk',
                'role' => RoleConstants::ROLE_CHAIRMAN,
            ],
            [
                'name' => 'Office Staff Member',
                'email' => 'office@uetmardan.edu.pk',
                'role' => RoleConstants::ROLE_OFFICE,
            ],
            [
                'name' => 'Faculty Dean',
                'email' => 'dean@uetmardan.edu.pk',
                'role' => RoleConstants::ROLE_DEAN,
            ],
            [
                'name' => 'System Administrator',
                'email' => 'admin@uetmardan.edu.pk',
                'role' => RoleConstants::ROLE_ADMIN,
            ],
        ];

        foreach ($users as $userData) {
            $user = User::updateOrCreate(
                ['email' => $userData['email']],
                [
                    'name' => $userData['name'],
                    'password' => $passwordHash,
                    'department_id' => $department->id,
                    'status' => 'approved',
                ]
            );

            $user->syncRoles([$userData['role']]);
        }
    }
}
