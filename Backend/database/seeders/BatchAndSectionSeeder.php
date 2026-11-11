<?php

namespace Database\Seeders;

use App\Models\Batch;
use App\Models\Campus;
use App\Models\Department;
use App\Models\Faculty;
use App\Models\Section;
use Illuminate\Database\Seeder;

class BatchAndSectionSeeder extends Seeder
{
    public function run(): void
    {
        $campus = Campus::firstOrCreate(
            ['code' => 'MC'],
            ['name' => 'Main Campus']
        );

        $faculty = Faculty::firstOrCreate(
            ['code' => 'ENG'],
            ['campus_id' => $campus->id, 'name' => 'Faculty of Electrical & Computer Engineering']
        );

        $defaultDept = Department::firstOrCreate(
            ['code' => 'CS'],
            ['faculty_id' => $faculty->id, 'name' => 'Department of Computer Science', 'is_active' => true]
        );
        if (!$defaultDept->faculty_id) {
            $defaultDept->update(['faculty_id' => $faculty->id]);
        }
        $defaultDeptId = $defaultDept->id;

        $batches = [
            ['name' => 'Batch 2022-2026', 'start_year' => 2022, 'end_year' => 2026],
            ['name' => 'Batch 2023-2027', 'start_year' => 2023, 'end_year' => 2027],
            ['name' => 'Batch 2024-2028', 'start_year' => 2024, 'end_year' => 2028],
            ['name' => 'Batch 2025-2029', 'start_year' => 2025, 'end_year' => 2029],
        ];

        foreach ($batches as $bData) {
            $batch = Batch::updateOrCreate(
                ['name' => $bData['name']],
                [
                    'department_id' => $defaultDeptId,
                    'start_year' => $bData['start_year'],
                    'end_year' => $bData['end_year'],
                    'is_active' => true,
                ]
            );

            foreach (['Section A', 'Section B', 'Section C'] as $secName) {
                Section::firstOrCreate(
                    ['batch_id' => $batch->id, 'name' => $secName]
                );
            }
        }
    }
}
