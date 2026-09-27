<?php

namespace Database\Seeders;

use App\Models\AppNotification;
use App\Models\Batch;
use App\Models\Complaint;
use App\Models\ComplaintRemark;
use App\Models\ComplaintTimeline;
use App\Models\Notice;
use App\Models\Section;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $defaultPassword = Hash::make('Password123!');

        // 1. Seed Roles & Users
        $admin = User::create([
            'name' => 'Department Admin',
            'email' => 'admin@uetmardan.edu.pk',
            'role' => 'admin',
            'password' => $defaultPassword,
            'email_verified_at' => now(),
            'is_profile_completed' => true,
        ]);

        $chairman = User::create([
            'name' => 'Prof. Dr. Chairman CS',
            'email' => 'chairman.cs@uetmardan.edu.pk',
            'role' => 'chairman',
            'password' => $defaultPassword,
            'email_verified_at' => now(),
            'is_profile_completed' => true,
        ]);

        $coordinator = User::create([
            'name' => 'Dr. Academic Coordinator',
            'email' => 'coordinator.cs@uetmardan.edu.pk',
            'role' => 'coordinator',
            'password' => $defaultPassword,
            'email_verified_at' => now(),
            'is_profile_completed' => true,
        ]);

        $adviser2022 = User::create([
            'name' => 'Engr. Batch Adviser (2022-26)',
            'email' => 'adviser.2022@uetmardan.edu.pk',
            'role' => 'batch_adviser',
            'password' => $defaultPassword,
            'phone' => '+92-300-1122334',
            'email_verified_at' => now(),
            'is_profile_completed' => true,
        ]);

        $office = User::create([
            'name' => 'CS Department Office Staff',
            'email' => 'office.cs@uetmardan.edu.pk',
            'role' => 'office_staff',
            'password' => $defaultPassword,
            'email_verified_at' => now(),
            'is_profile_completed' => true,
        ]);

        $dean = User::create([
            'name' => 'Dean Faculty of Engineering',
            'email' => 'dean.fet@uetmardan.edu.pk',
            'role' => 'dean',
            'password' => $defaultPassword,
            'email_verified_at' => now(),
            'is_profile_completed' => true,
        ]);

        $cr = User::create([
            'name' => 'Ali Khan (CR)',
            'email' => 'cr.2022@uetmardan.edu.pk',
            'role' => 'cr',
            'password' => $defaultPassword,
            'reg_no' => '22-CS-01',
            'batch' => '2022-2026',
            'section' => 'A',
            'phone' => '+92-312-9876543',
            'email_verified_at' => now(),
            'is_profile_completed' => true,
        ]);

        $student = User::create([
            'name' => 'Muhammad Usman',
            'email' => 'student.cs@uetmardan.edu.pk',
            'role' => 'student',
            'password' => $defaultPassword,
            'reg_no' => '22-CS-45',
            'batch' => '2022-2026',
            'section' => 'A',
            'phone' => '+92-333-1234567',
            'email_verified_at' => now(),
            'is_profile_completed' => true,
        ]);

        // 2. Seed Academic Batches
        $batch2022 = Batch::create([
            'name' => '2022-2026',
            'year' => 3,
            'adviser_id' => $adviser2022->id,
        ]);

        $batch2023 = Batch::create([
            'name' => '2023-2027',
            'year' => 2,
            'adviser_id' => $adviser2022->id,
        ]);

        $batch2024 = Batch::create([
            'name' => '2024-2028',
            'year' => 1,
            'adviser_id' => $adviser2022->id,
        ]);

        // Seed Sections
        Section::create(['batch_id' => $batch2022->id, 'name' => 'A', 'cr_id' => $cr->id]);
        Section::create(['batch_id' => $batch2022->id, 'name' => 'B']);
        Section::create(['batch_id' => $batch2023->id, 'name' => 'A']);
        Section::create(['batch_id' => $batch2024->id, 'name' => 'A']);

        // 3. Seed Sample Complaints with Full Workflow Lifecycles
        $complaint1 = Complaint::create([
            'tracking_number' => 'DCMS-2026-CS894',
            'title' => 'Software Engineering Lab GPU PC System Failures',
            'description' => 'PCs in SE Lab (Room 204) are restarting intermittently during AI lab sessions. Multiple students cannot execute model training tasks.',
            'category' => 'Lab & Equipment',
            'status' => 'forwarded_to_chairman',
            'priority' => 'high',
            'student_id' => $student->id,
            'batch' => '2022-2026',
            'section' => 'A',
            'current_handler_role' => 'chairman',
            'current_handler_id' => $chairman->id,
            'attachment_urls' => [],
        ]);

        ComplaintTimeline::create([
            'complaint_id' => $complaint1->id,
            'actor_id' => $student->id,
            'actor_name' => $student->name,
            'actor_role' => 'student',
            'action' => 'Submitted',
            'status_after' => 'submitted',
            'remarks' => 'Complaint lodged by student.',
        ]);

        ComplaintTimeline::create([
            'complaint_id' => $complaint1->id,
            'actor_id' => $adviser2022->id,
            'actor_name' => $adviser2022->name,
            'actor_role' => 'batch_adviser',
            'action' => 'Forwarded',
            'status_after' => 'forwarded_to_coordinator',
            'remarks' => 'Verified on-site. 6 workstations require power supply inspection.',
        ]);

        ComplaintTimeline::create([
            'complaint_id' => $complaint1->id,
            'actor_id' => $coordinator->id,
            'actor_name' => $coordinator->name,
            'actor_role' => 'coordinator',
            'action' => 'Forwarded',
            'status_after' => 'forwarded_to_chairman',
            'remarks' => 'Forwarding to Chairman for lab technician dispatch authorization.',
        ]);

        ComplaintRemark::create([
            'complaint_id' => $complaint1->id,
            'author_id' => $adviser2022->id,
            'author_name' => $adviser2022->name,
            'author_role' => 'batch_adviser',
            'content' => 'Inspected Room 204 during 4th period. Technician informed.',
            'is_official' => true,
        ]);

        // Complaint 2: Resolved
        $complaint2 = Complaint::create([
            'tracking_number' => 'DCMS-2026-CS102',
            'title' => 'Midterm Exam Schedule Conflict with Final Year Project Defense',
            'description' => 'The Midterm schedule for Distributed Systems coincides with the FYP Phase 1 presentation slot.',
            'category' => 'Examination & Results',
            'status' => 'resolved',
            'priority' => 'urgent',
            'student_id' => $student->id,
            'batch' => '2022-2026',
            'section' => 'A',
            'current_handler_role' => 'coordinator',
            'current_handler_id' => $coordinator->id,
            'resolved_at' => now(),
        ]);

        ComplaintTimeline::create([
            'complaint_id' => $complaint2->id,
            'actor_id' => $student->id,
            'actor_name' => $student->name,
            'actor_role' => 'student',
            'action' => 'Submitted',
            'status_after' => 'submitted',
            'remarks' => 'Lodged.',
        ]);

        ComplaintTimeline::create([
            'complaint_id' => $complaint2->id,
            'actor_id' => $coordinator->id,
            'actor_name' => $coordinator->name,
            'actor_role' => 'coordinator',
            'action' => 'Resolved',
            'status_after' => 'resolved',
            'remarks' => 'Exam timetable updated. Distributed Systems moved to 2:00 PM.',
        ]);

        // 4. Seed Department Notices
        Notice::create([
            'title' => 'Midterm Examination Schedule Fall 2026',
            'content' => 'All Department of Computer Science students are advised to review the official midterm timetable posted on the departmental portal.',
            'target' => 'all',
            'author_id' => $coordinator->id,
            'author_name' => $coordinator->name,
            'author_role' => 'coordinator',
            'is_pinned' => true,
        ]);

        Notice::create([
            'title' => 'Batch 2022-2026: FYP Supervisor Selection Deadline',
            'content' => 'Final Year students must submit their project proposal synopsis signed by their respective supervisor before October 15th.',
            'target' => 'batch',
            'target_value' => '2022-2026',
            'author_id' => $chairman->id,
            'author_name' => $chairman->name,
            'author_role' => 'chairman',
            'is_pinned' => false,
        ]);

        // 5. Seed Notification
        AppNotification::create([
            'user_id' => $student->id,
            'title' => 'Complaint #DCMS-2026-CS894 Updated',
            'message' => 'Your complaint has been forwarded to the Chairman CS for assessment.',
            'type' => 'complaint_forwarded',
            'reference_id' => (string) $complaint1->id,
            'is_read' => false,
        ]);
    }
}
