<?php

namespace Database\Seeders;

use App\Models\ComplaintCategory;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class ComplaintCategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'Academic', 'description' => 'Issues related to academics, courses, and faculty.'],
            ['name' => 'Infrastructure', 'description' => 'Issues related to facilities, labs, and classrooms.'],
            ['name' => 'Exam', 'description' => 'Issues related to examinations and grading.'],
            ['name' => 'General', 'description' => 'General inquiries and non-specific issues.'],
        ];

        foreach ($categories as $category) {
            ComplaintCategory::updateOrCreate(
                ['slug' => Str::slug($category['name'])],
                [
                    'name' => $category['name'],
                    'description' => $category['description'],
                    'is_active' => true,
                ]
            );
        }
    }
}
