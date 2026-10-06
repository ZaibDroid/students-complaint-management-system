<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class MediaTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Role::firstOrCreate(['name' => 'Student']);
    }

    public function test_student_can_upload_and_delete_application_attachment()
    {
        Storage::fake('public');

        $student = User::factory()->create();
        $student->assignRole('Student');

        $application = \App\Models\Application::factory()->create([
            'student_id' => $student->id
        ]);

        $file = UploadedFile::fake()->create('document.pdf', 100);

        $response = $this->actingAs($student)->postJson("/api/v1/applications/{$application->id}/attachments", [
            'attachments' => [$file]
        ]);

        $response->assertStatus(200);

        // Assert file exists in storage
        $this->assertDatabaseHas('applications', [
            'id' => $application->id,
            'attachment_name' => 'document.pdf'
        ]);

        $application->refresh();
        $path = str_replace(asset('storage/'), '', $application->attachment_path);
        Storage::disk('public')->assertExists($path);

        // Delete attachment
        $deleteResponse = $this->actingAs($student)->deleteJson("/api/v1/applications/attachments/{$application->id}");

        $deleteResponse->assertStatus(200);

        $this->assertDatabaseHas('applications', [
            'id' => $application->id,
            'attachment_path' => null
        ]);

        Storage::disk('public')->assertMissing($path);
    }
}
