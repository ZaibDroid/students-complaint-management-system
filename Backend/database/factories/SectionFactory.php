<?php

namespace Database\Factories;

use App\Models\Batch;
use App\Models\Section;
use Illuminate\Database\Eloquent\Factories\Factory;

class SectionFactory extends Factory
{
    protected $model = Section::class;

    public function definition(): array
    {
        return [
            'batch_id' => Batch::factory(),
            'name' => 'Section ' . $this->faker->randomLetter(),
            'is_active' => true,
        ];
    }
}
