<?php

namespace App\Constants;

class AppConstants
{
    // Pagination Defaults
    public const DEFAULT_PAGINATION_PER_PAGE = 15;
    public const MAX_PAGINATION_PER_PAGE = 100;

    // Email Domain Restraints
    public const ALLOWED_EMAIL_DOMAIN = 'uetmardan.edu.pk';

    // Status Codes & Messages
    public const STATUS_SUCCESS = 'success';
    public const STATUS_ERROR = 'error';

    // Default Date Format
    public const DATE_FORMAT = 'Y-m-d H:i:s';
}
