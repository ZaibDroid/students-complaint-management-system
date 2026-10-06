<?php

namespace Tests\Feature;

use App\Models\Department;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NotificationTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);

        $dept = Department::firstOrCreate(['code' => 'CS'], ['name' => 'Computer Science']);

        $this->user = User::factory()->create([
            'email' => 'user.notif@uetmardan.edu.pk',
            'department_id' => $dept->id,
            'status' => 'approved',
        ]);
        $this->user->assignRole('Student');
    }

    public function test_user_can_fetch_notifications(): void
    {
        Notification::create([
            'user_id' => $this->user->id,
            'title' => 'Test Notification',
            'message' => 'Notification body content',
            'type' => \App\Enums\NotificationType::SystemAnnouncement->value,
        ]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/notifications');

        $response->assertStatus(200)
            ->assertJsonPath('success', true);
    }

    public function test_user_can_mark_notification_as_read(): void
    {
        $notif = Notification::create([
            'user_id' => $this->user->id,
            'title' => 'Unread Notification',
            'message' => 'Notification body content',
            'type' => \App\Enums\NotificationType::ApplicationUpdated->value,
        ]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->patchJson("/api/v1/notifications/{$notif->id}/read");

        $response->assertStatus(200)
            ->assertJsonPath('success', true);

        $this->assertNotNull($notif->fresh()->read_at);
    }
}
