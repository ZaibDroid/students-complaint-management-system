<?php

namespace App\Constants;

class RoleConstants
{
    // User Roles
    public const ROLE_STUDENT = 'Student';
    public const ROLE_CR = 'Class Representative';
    public const ROLE_ADVISER = 'Batch Adviser';
    public const ROLE_COORDINATOR = 'Coordinator';
    public const ROLE_CHAIRMAN = 'Chairman';
    public const ROLE_OFFICE = 'Office Staff';
    public const ROLE_DEAN = 'Dean';
    public const ROLE_VC = 'Vice Chancellor';
    public const ROLE_ADMIN = 'Admin';

    // Role List
    public static function allRoles(): array
    {
        return [
            self::ROLE_STUDENT,
            self::ROLE_CR,
            self::ROLE_ADVISER,
            self::ROLE_COORDINATOR,
            self::ROLE_CHAIRMAN,
            self::ROLE_OFFICE,
            self::ROLE_DEAN,
            self::ROLE_VC,
            self::ROLE_ADMIN,
        ];
    }
}
