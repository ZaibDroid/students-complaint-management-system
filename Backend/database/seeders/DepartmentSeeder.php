<?php

namespace Database\Seeders;

use App\Models\Department;
use Illuminate\Database\Seeder;

class DepartmentSeeder extends Seeder
{
    /**
     * Seed the 8 official departments of UET Mardan.
     */
    public function run(): void
    {
        $departments = [
            ['code' => 'CS', 'name' => 'Computer Science'],
            ['code' => 'NS', 'name' => 'Natural Sciences'],
            ['code' => 'CAI', 'name' => 'Center of AI'],
            ['code' => 'CIV', 'name' => 'Civil Engineering'],
            ['code' => 'EE', 'name' => 'Electrical Engineering'],
            ['code' => 'ME', 'name' => 'Mechanical Engineering'],
            ['code' => 'SE', 'name' => 'Software Engineering'],
            ['code' => 'TE', 'name' => 'Telecommunication Engineering'],
        ];

        foreach ($departments as $d) {
            $dept = Department::where('code', $d['code'])
                ->orWhere('name', $d['name'])
                ->orWhere('name', 'Department of ' . $d['name'])
                ->first();

            if ($dept) {
                $dept->update([
                    'name' => $d['name'],
                    'code' => $d['code'],
                    'is_active' => true,
                ]);
            } else {
                Department::create([
                    'name' => $d['name'],
                    'code' => $d['code'],
                    'is_active' => true,
                ]);
            }
        }
    }
}

