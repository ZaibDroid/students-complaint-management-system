<?php

namespace Database\Factories;

use App\Models\Application;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class ApplicationFactory extends Factory
{
    protected $model = Application::class;

    public function definition(): array
    {
        return [
            'ticket_number' => 'APP-' . strtoupper($this->faker->unique()->bothify('?????-#####')),
            'title' => $this->faker->sentence(),
            'description' => $this->faker->paragraph(),
            'student_id' => User::factory(),
            'assigned_to_id' => User::factory(),
            'status' => 'pending',
            'priority' => 'normal',
        ];
    }
}
