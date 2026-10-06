<?php

namespace Database\Factories;

use App\Models\Complaint;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class ComplaintFactory extends Factory
{
    protected $model = Complaint::class;

    public function definition(): array
    {
        return [
            'ticket_number' => 'DCMS-2026-' . fake()->unique()->numberBetween(1000, 9999),
            'student_id' => User::factory(),
            'title' => fake()->sentence(),
            'description' => fake()->paragraph(),
            'category' => fake()->randomElement(['Academic', 'Infrastructure', 'Exam']),
            'status' => 'submitted',
            'priority' => 'medium',
        ];
    }
}
