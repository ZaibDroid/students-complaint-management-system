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
                'registration_number' => '23MDBCS501',
                'current_semester' => 4,
                'role' => RoleConstants::ROLE_STUDENT,
            ],
            [
                'name' => 'Batch Adviser',
                'email' => 'adviser@uetmardan.edu.pk',
                'registration_number' => 'FAC-CS-001',
                'role' => RoleConstants::ROLE_ADVISER,
            ],
            [
                'name' => 'Department Coordinator',
                'email' => 'coordinator@uetmardan.edu.pk',
                'registration_number' => 'FAC-CS-002',
                'role' => RoleConstants::ROLE_COORDINATOR,
            ],
            [
                'name' => 'Department Chairman',
                'email' => 'chairman@uetmardan.edu.pk',
                'registration_number' => 'FAC-CS-003',
                'role' => RoleConstants::ROLE_CHAIRMAN,
            ],
            [
                'name' => 'Office Staff Member',
                'email' => 'office@uetmardan.edu.pk',
                'registration_number' => 'STF-CS-001',
                'role' => RoleConstants::ROLE_OFFICE,
            ],
            [
                'name' => 'Faculty Dean',
                'email' => 'dean@uetmardan.edu.pk',
                'registration_number' => 'FAC-ENG-001',
                'role' => RoleConstants::ROLE_DEAN,
            ],
            [
                'name' => 'System Administrator',
                'email' => 'admin@uetmardan.edu.pk',
                'registration_number' => 'ADM-SYS-001',
                'role' => RoleConstants::ROLE_ADMIN,
            ],
        ];

        foreach ($users as $userData) {
            $user = User::updateOrCreate(
                ['email' => $userData['email']],
                [
                    'name' => $userData['name'],
                    'registration_number' => $userData['registration_number'],
                    'current_semester' => $userData['current_semester'] ?? null,
                    'password' => $passwordHash,
                    'department_id' => $department->id,
                    'status' => 'approved',
                ]
            );

            $user->syncRoles([$userData['role']]);
        }
    }
}
