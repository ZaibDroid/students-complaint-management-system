<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Database\Seeders\RoleAndPermissionSeeder;

abstract class TestCase extends BaseTestCase
{
    use CreatesApplication, RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Seed roles and permissions for all tests
        $this->seed(RoleAndPermissionSeeder::class);
    }
}
