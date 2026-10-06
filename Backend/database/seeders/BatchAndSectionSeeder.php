<?php

namespace Database\Seeders;

use App\Models\Batch;
use App\Models\Section;
use Illuminate\Database\Seeder;

class BatchAndSectionSeeder extends Seeder
{
    public function run(): void
    {
        $batches = [
            ['name' => 'Batch 2022-2026', 'start_year' => 2022, 'end_year' => 2026],
            ['name' => 'Batch 2023-2027', 'start_year' => 2023, 'end_year' => 2027],
            ['name' => 'Batch 2024-2028', 'start_year' => 2024, 'end_year' => 2028],
            ['name' => 'Batch 2025-2029', 'start_year' => 2025, 'end_year' => 2029],
        ];

        foreach ($batches as $bData) {
            $batch = Batch::firstOrCreate(
                ['name' => $bData['name']],
                [
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
