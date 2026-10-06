<?php

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Seeder;

class SettingSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            [
                'key' => 'app_name',
                'value' => 'Department Complaint Management System',
                'group' => 'general',
            ],
            [
                'key' => 'academic_year',
                'value' => '2025-2026',
                'group' => 'general',
            ],
            [
                'key' => 'registration_enabled',
                'value' => '1',
                'group' => 'general',
            ],
            [
                'key' => 'max_attachment_size_mb',
                'value' => '10',
                'group' => 'uploads',
            ],
            [
                'key' => 'auto_assign_adviser',
                'value' => '1',
                'group' => 'general',
            ],
        ];

        foreach ($settings as $setting) {
            Setting::updateOrCreate(
                ['key' => $setting['key']],
                [
                    'value' => $setting['value'],
                    'group' => $setting['group'],
                ]
            );
        }
    }
}
