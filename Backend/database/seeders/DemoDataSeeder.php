<?php

namespace Database\Seeders;

use App\Models\Complaint;
use App\Models\ComplaintRemark;
use App\Models\ComplaintTimeline;
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

        // Demo Complaints
        $c1 = Complaint::create([
            'student_id' => $student->id,
            'assigned_to_id' => $adviser->id,
            'title' => 'Projector not functioning in Lab 3',
            'description' => 'The multimedia projector display flickers continuously during the afternoon lectures.',
            'category' => 'Infrastructure',
            'status' => 'pending',
            'priority' => 'medium',
        ]);

        ComplaintTimeline::create([
            'complaint_id' => $c1->id,
            'action' => 'submitted',
            'from_user_id' => $student->id,
            'to_user_id' => $adviser->id,
            'notes' => 'Complaint submitted by student.',
        ]);

        ComplaintRemark::create([
            'complaint_id' => $c1->id,
            'user_id' => $adviser->id,
            'remark' => 'Inspected lab projector. Lab technician notified for repair.',
            'action_taken' => 'Inspected',
        ]);

        $c2 = Complaint::create([
            'student_id' => $student->id,
            'assigned_to_id' => $coordinator->id,
            'title' => 'Timetable overlap for CS-301 and CS-305',
            'description' => 'Algorithm Design and Database Systems classes are scheduled at the exact same hour on Monday.',
            'category' => 'Academic',
            'status' => 'forwarded',
            'priority' => 'high',
        ]);

        ComplaintTimeline::create([
            'complaint_id' => $c2->id,
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
        ]);

        Notice::create([
            'sender_id' => $coordinator->id,
            'title' => 'Lab Maintenance Session',
            'description' => 'Computer Lab 1 and 2 will remain closed on Friday for network maintenance.',
            'tag' => 'General',
        ]);

        // Demo Notifications
        Notification::create([
            'user_id' => $student->id,
            'title' => 'Complaint Status Update',
            'body' => 'Your complaint "Projector not functioning in Lab 3" is under review.',
            'category' => 'Complaints',
            'related_id' => (string) $c1->id,
            'is_read' => false,
        ]);
    }
}
