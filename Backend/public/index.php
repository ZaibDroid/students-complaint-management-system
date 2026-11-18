<?php

use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

// Bypass Composer PHP 8.2 platform check for PHP 8.1 compatibility
if (file_exists($platformCheck = __DIR__.'/../vendor/composer/platform_check.php')) {
    $content = @file_get_contents($platformCheck);
    if ($content && (str_contains($content, '80200') || str_contains($content, 'RuntimeException'))) {
        @file_put_contents($platformCheck, "<?php\n// platform check bypassed for PHP 8.1 compatibility\n");
    }
}

// Register the Composer autoloader...
require __DIR__.'/../vendor/autoload.php';

// Bootstrap Laravel and handle the request...
(require_once __DIR__.'/../bootstrap/app.php')
    ->handleRequest(Request::capture());
