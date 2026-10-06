<?php

namespace Database\Factories;

use App\Models\ApplicationCategory;
use Illuminate\Database\Eloquent\Factories\Factory;

class ApplicationCategoryFactory extends Factory
{
    protected $model = ApplicationCategory::class;

    public function definition(): array
    {
        $name = $this->faker->words(3, true);
        return [
            'name' => $name,
            'slug' => \Illuminate\Support\Str::slug($name),
            'description' => $this->faker->sentence(),
            'is_active' => true,
        ];
    }
}
