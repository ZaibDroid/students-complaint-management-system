<?php

namespace Database\Seeders;

use App\Enums\NotificationType;
use App\Models\Application;
use App\Models\ApplicationCategory;
use App\Models\ApplicationRemark;
use App\Models\ApplicationTimeline;
use App\Models\Notice;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Database\Seeder;

class DemoDataSeeder extends Seeder
{
    public function run(): void
    {
        $student = User::where('email', 'student@uetmardan.edu.pk')->first();
        $adviser = User::where('email', 'adviser@uetmardan.edu.pk')->first();
        $coordinator = User::where('email', 'coordinator@uetmardan.edu.pk')->first();

        if (!$student || !$adviser || !$coordinator) {
            return;
        }

        // Categories
        $infraCat = ApplicationCategory::firstOrCreate(
            ['slug' => 'infrastructure'],
            ['name' => 'Infrastructure', 'description' => 'Facilities, classrooms, and hardware issues', 'is_active' => true]
        );

        $academicCat = ApplicationCategory::firstOrCreate(
            ['slug' => 'academic'],
            ['name' => 'Academic', 'description' => 'Courses, timetable, and faculty matters', 'is_active' => true]
        );

        ApplicationCategory::firstOrCreate(
            ['slug' => 'administrative'],
            ['name' => 'Administrative', 'description' => 'Documentation, certificates, and administration', 'is_active' => true]
        );

        // Demo Complaints / Applications
        $c1 = Application::create([
            'student_id' => $student->id,
            'assigned_to_id' => $adviser->id,
            'category_id' => $infraCat->id,
            'title' => 'Projector not functioning in Lab 3',
            'description' => 'The multimedia projector display flickers continuously during the afternoon lectures.',
            'status' => 'pending',
            'priority' => 'medium',
        ]);

        ApplicationTimeline::create([
            'application_id' => $c1->id,
            'action' => 'submitted',
            'from_user_id' => $student->id,
            'to_user_id' => $adviser->id,
            'notes' => 'Complaint submitted by student.',
        ]);

        ApplicationRemark::create([
            'application_id' => $c1->id,
            'user_id' => $adviser->id,
            'remark' => 'Inspected lab projector. Lab technician notified for repair.',
            'action_taken' => 'Inspected',
        ]);

        $c2 = Application::create([
            'student_id' => $student->id,
            'assigned_to_id' => $coordinator->id,
            'category_id' => $academicCat->id,
            'title' => 'Timetable overlap for CS-301 and CS-305',
            'description' => 'Algorithm Design and Database Systems classes are scheduled at the exact same hour on Monday.',
            'status' => 'forwarded',
            'priority' => 'high',
        ]);

        ApplicationTimeline::create([
            'application_id' => $c2->id,
            'action' => 'forwarded',
            'from_user_id' => $adviser->id,
            'to_user_id' => $coordinator->id,
            'notes' => 'Forwarded to Department Coordinator for timetable revision.',
        ]);

        // Demo Notices
        Notice::create([
            'sender_id' => $coordinator->id,
            'title' => 'Midterm Examination Schedule Released',
            'description' => 'Spring 2026 Midterm Exams will commence from next Monday. Check notice board for timetable.',
            'tag' => 'Academic',
            'status' => Notice::STATUS_PUBLISHED,
            'published_at' => now(),
        ]);

        Notice::create([
            'sender_id' => $coordinator->id,
            'title' => 'Lab Maintenance Session',
            'description' => 'Computer Lab 1 and 2 will remain closed on Friday for network maintenance.',
            'tag' => 'General',
            'status' => Notice::STATUS_PUBLISHED,
            'published_at' => now(),
        ]);

        // Demo Notifications
        Notification::create([
            'user_id' => $student->id,
            'type' => NotificationType::ApplicationUpdated,
            'reference_type' => Application::class,
            'reference_id' => $c1->id,
            'title' => 'Complaint Status Update',
            'message' => 'Your complaint "Projector not functioning in Lab 3" is under review.',
        ]);
    }
}
