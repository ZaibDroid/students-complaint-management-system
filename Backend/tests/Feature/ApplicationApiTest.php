<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Application;
use App\Models\ApplicationCategory;
use Tests\TestCase;

class ApplicationApiTest extends TestCase
{
    public function test_student_can_submit_application()
    {
        $adviser = User::factory()->create();
        $adviser->assignRole('Batch Adviser');
        $student = User::factory()->create(['adviser_id' => $adviser->id]);
        $student->assignRole('Student');
        
        $category = ApplicationCategory::factory()->create();

        $response = $this->actingAs($student)->postJson('/api/v1/applications', [
            'title' => 'Test Application',
            'description' => 'This is a test application',
            'category_id' => $category->id,
            'is_anonymous' => false,
        ]);

        $response->assertStatus(201)
                 ->assertJsonStructure([
                     'data' => [
                         'id',
                         'ticket_number',
                         'status'
                     ]
                 ]);
    }
}
