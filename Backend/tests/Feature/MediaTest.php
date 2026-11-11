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

        // Assert file exists in relational attachments table
        $this->assertDatabaseHas('application_attachments', [
            'application_id' => $application->id,
            'file_name' => 'document.pdf'
        ]);

        $attachment = \App\Models\ApplicationAttachment::where('application_id', $application->id)->first();
        $this->assertNotNull($attachment);
        Storage::disk('public')->assertExists($attachment->file_path);

        // Delete attachment
        $deleteResponse = $this->actingAs($student)->deleteJson("/api/v1/applications/attachments/{$application->id}");

        $deleteResponse->assertStatus(200);

        $this->assertDatabaseMissing('application_attachments', [
            'application_id' => $application->id,
        ]);

        Storage::disk('public')->assertMissing($attachment->file_path);
    }
}
