<?php

return [
    /*
    |--------------------------------------------------------------------------
    | DCMS Specific Settings for UET Mardan
    |--------------------------------------------------------------------------
    */

    'allowed_email_domain' => env('ALLOWED_EMAIL_DOMAIN', 'uetmardan.edu.pk'),

    'roles' => [
        'student' => 'Student',
        'cr' => 'Class Representative (CR)',
        'batch_adviser' => 'Batch Adviser',
        'coordinator' => 'Coordinator',
        'chairman' => 'Chairman',
        'office_staff' => 'Office Staff',
        'dean' => 'Dean',
        'admin' => 'Admin',
    ],

    'complaint_statuses' => [
        'submitted' => 'Submitted',
        'under_review' => 'Under Review',
        'forwarded_to_coordinator' => 'Forwarded to Coordinator',
        'forwarded_to_chairman' => 'Forwarded to Chairman',
        'forwarded_to_office' => 'Forwarded to Office Staff',
        'forwarded_to_dean' => 'Forwarded to Dean',
        'returned' => 'Returned',
        'resolved' => 'Resolved',
        'rejected' => 'Rejected',
    ],

    'priorities' => ['low', 'medium', 'high', 'urgent'],

    'categories' => [
        'Academic Issues',
        'Faculty / Teaching',
        'Lab & Equipment',
        'Examination & Results',
        'Hostel / Transport',
        'Fee & Scholarships',
        'Administrative / Office',
        'Other',
    ],

    'workflow_hierarchy' => [
        'student' => ['batch_adviser'],
        'cr' => ['batch_adviser'],
        'batch_adviser' => ['coordinator', 'chairman', 'student'],
        'coordinator' => ['chairman', 'batch_adviser'],
        'chairman' => ['office_staff', 'dean', 'coordinator', 'batch_adviser', 'student'],
        'office_staff' => ['chairman'],
        'dean' => ['chairman'],
        'admin' => ['student', 'cr', 'batch_adviser', 'coordinator', 'chairman', 'office_staff', 'dean', 'admin'],
    ],

    'fcm' => [
        'server_key' => env('FCM_SERVER_KEY', ''),
        'project_id' => env('FCM_PROJECT_ID', 'dcms-uetmardan'),
        'service_account' => env('FCM_SERVICE_ACCOUNT_JSON', ''),
    ],
];
