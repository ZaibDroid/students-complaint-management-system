<?php

namespace Database\Seeders;

use App\Constants\RoleConstants;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class RoleAndPermissionSeeder extends Seeder
{
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[PermissionRegistrar::class]->forgetCachedPermissions();

        // Ensure roles exist
        foreach (RoleConstants::allRoles() as $roleName) {
            Role::firstOrCreate(['name' => $roleName, 'guard_name' => 'web']);
        }

        // Define matrix mapping Roles to specific Permissions
        $rolePermissions = [
            RoleConstants::ROLE_STUDENT => [
                'applications.create',
                'applications.view_own',
                'notices.view',
            ],
            RoleConstants::ROLE_ADVISER => [
                'applications.view_assigned',
                'applications.forward',
            ],
            RoleConstants::ROLE_COORDINATOR => [
                'applications.resolve',
                'notices.create',
            ],
            RoleConstants::ROLE_CHAIRMAN => [
                'applications.view_department',
                'reports.export',
                'audit.view',
            ],
            // Admin gets all permissions dynamically
        ];

        // Collect all unique permissions
        $allPermissions = collect($rolePermissions)->flatten()->unique();

        // Create Permissions
        foreach ($allPermissions as $permissionName) {
            Permission::firstOrCreate(['name' => $permissionName, 'guard_name' => 'web']);
        }

        // Assign Specific Permissions to Roles
        foreach ($rolePermissions as $roleName => $permissions) {
            $role = Role::findByName($roleName, 'web');
            $role->syncPermissions($permissions);
        }

        // Assign All Permissions to Admin Role
        $adminRole = Role::findByName(RoleConstants::ROLE_ADMIN, 'web');
        $adminRole->syncPermissions(Permission::all());
    }
}
