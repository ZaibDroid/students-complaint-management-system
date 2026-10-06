<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\BatchController;
use App\Http\Controllers\Api\V1\ApplicationAttachmentController;
use App\Http\Controllers\Api\V1\ApplicationController;
use App\Http\Controllers\Api\V1\ApplicationRemarkController;
use App\Http\Controllers\Api\V1\ApplicationTimelineController;
use App\Http\Controllers\Api\V1\CrManagementController;
use App\Http\Controllers\Api\V1\DashboardController;
use App\Http\Controllers\Api\V1\DepartmentController;
use App\Http\Controllers\Api\V1\NoticeAttachmentController;
use App\Http\Controllers\Api\V1\NoticeController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\ReportController;
use App\Http\Controllers\Api\V1\SectionController;
use App\Http\Controllers\Api\V1\SettingController;
use App\Http\Controllers\Api\V1\UserController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes - Version 1
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // System Health Check Endpoint
    Route::get('/health', function () {
        return response()->json([
            'success' => true,
            'message' => 'DCMS API Version 1 is operational',
            'data' => [
                'environment' => config('app.env'),
                'timezone' => config('app.timezone'),
                'version' => '1.0.0',
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    });

    /*
    |--------------------------------------------------------------------------
    | Public Routes (Lookup & Settings endpoints)
    |--------------------------------------------------------------------------
    */
    Route::prefix('settings')->group(function () {
        Route::get('/', [SettingController::class, 'index']);
    });

    Route::prefix('departments')->group(function () {
        Route::get('/', [DepartmentController::class, 'index']);
        Route::get('/{department}', [DepartmentController::class, 'show']);
    });

    Route::prefix('batches')->group(function () {
        Route::get('/', [BatchController::class, 'index']);
        Route::get('/{batch}', [BatchController::class, 'show']);
    });

    Route::prefix('sections')->group(function () {
        Route::get('/', [SectionController::class, 'index']);
        Route::get('/{section}', [SectionController::class, 'show']);
    });

    Route::prefix('crs')->group(function () {
        Route::get('/', [CrManagementController::class, 'index']);
    });

    /*
    |--------------------------------------------------------------------------
    | Authentication Routes (Public)
    |--------------------------------------------------------------------------
    */
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'registerStudent']);
        Route::post('/login', [AuthController::class, 'login']);
    });

    /*
    |--------------------------------------------------------------------------
    | Protected Routes (Sanctum Middleware)
    |--------------------------------------------------------------------------
    */
    Route::middleware('auth:sanctum')->group(function () {

        // Authenticated User Profile Endpoints
        Route::prefix('auth')->group(function () {
            Route::post('/logout', [AuthController::class, 'logout']);
            Route::get('/me', [AuthController::class, 'me']);
            Route::put('/profile', [AuthController::class, 'updateProfile']);
            Route::put('/password', [AuthController::class, 'changePassword']);
            Route::post('/profile-image', [AuthController::class, 'uploadProfileImage']);
        });

        // Settings Admin Update
        Route::prefix('settings')->group(function () {
            Route::put('/', [SettingController::class, 'update']);
        });

        // Dashboard & Analytics Routes
        Route::prefix('dashboard')->group(function () {
            Route::get('/', [DashboardController::class, 'index']);
            Route::get('/charts', [DashboardController::class, 'getCharts']);
        });

        // Reports & Export Routes
        Route::prefix('reports')->group(function () {
            Route::get('/', [ReportController::class, 'generate']);
        });

        // In-App Notification Center Routes
        Route::prefix('notifications')->group(function () {
            Route::get('/', [NotificationController::class, 'index']);
            Route::patch('/read-all', [NotificationController::class, 'markAllAsRead']);
            Route::patch('/{notification}/read', [NotificationController::class, 'markAsRead']);
            Route::delete('/{notification}', [NotificationController::class, 'destroy']);
        });

        // Notice Board Engine Routes
        Route::prefix('notices')->group(function () {
            Route::get('/', [NoticeController::class, 'index']);
            Route::post('/', [NoticeController::class, 'store']);
            Route::get('/{notice}', [NoticeController::class, 'show']);
            Route::put('/{notice}', [NoticeController::class, 'update']);
            Route::delete('/{notice}', [NoticeController::class, 'destroy']);

            // Attachment management
            Route::post('/{notice}/attachment', [NoticeAttachmentController::class, 'upload']);
            Route::delete('/{notice}/attachment', [NoticeAttachmentController::class, 'destroy']);
        });

        // Application Engine Routes
        Route::prefix('application-categories')->group(function () {
            Route::get('/', [\App\Http\Controllers\Api\V1\ApplicationCategoryController::class, 'index']);
        });

        Route::prefix('applications')->group(function () {
            Route::get('/', [ApplicationController::class, 'index']);
            Route::post('/', [ApplicationController::class, 'store']);
            Route::get('/{application}', [ApplicationController::class, 'show']);
            Route::put('/{application}', [ApplicationController::class, 'update']);
            Route::put('/{application}/status', [ApplicationController::class, 'updateStatus']);
            Route::delete('/{application}', [ApplicationController::class, 'destroy']);

            // Attachments
            Route::post('/{application}/attachments', [ApplicationAttachmentController::class, 'store']);
            Route::delete('/attachments/{application}', [ApplicationAttachmentController::class, 'destroy']);

            // Remarks
            Route::get('/{application}/remarks', [ApplicationRemarkController::class, 'index']);
            Route::post('/{application}/remarks', [ApplicationRemarkController::class, 'store']);

            // Timeline History
            Route::get('/{application}/timeline', [ApplicationTimelineController::class, 'index']);
        });

        // Departments Admin CRUD
        Route::prefix('departments')->group(function () {
            Route::post('/', [DepartmentController::class, 'store']);
            Route::put('/{department}', [DepartmentController::class, 'update']);
            Route::delete('/{department}', [DepartmentController::class, 'destroy']);
        });

        // Batches Admin CRUD
        Route::prefix('batches')->group(function () {
            Route::post('/', [BatchController::class, 'store']);
            Route::put('/{batch}', [BatchController::class, 'update']);
            Route::delete('/{batch}', [BatchController::class, 'destroy']);
        });

        // Sections Admin CRUD & Adviser Assignment
        Route::prefix('sections')->group(function () {
            Route::post('/', [SectionController::class, 'store']);
            Route::put('/{section}', [SectionController::class, 'update']);
            Route::delete('/{section}', [SectionController::class, 'destroy']);
            Route::post('/{section}/adviser', [SectionController::class, 'assignAdviser']);
            Route::delete('/{section}/adviser/{adviserId}', [SectionController::class, 'removeAdviser']);
        });

        // CR Promotion Management
        Route::prefix('crs')->group(function () {
            Route::put('/{user}/status', [CrManagementController::class, 'updateStatus']);
        });

        // User & Staff Management Endpoints
        Route::prefix('users')->group(function () {
            Route::get('/', [UserController::class, 'index']);
            Route::get('/staff', [UserController::class, 'listStaff']);
            Route::get('/students', [UserController::class, 'listStudents']);
            Route::post('/staff', [UserController::class, 'createStaff']);
            Route::get('/{user}', [UserController::class, 'show']);
            Route::put('/staff/{user}', [UserController::class, 'updateStaff']);
            Route::delete('/staff/{user}', [UserController::class, 'deleteStaff']);

            // Role & Adviser Assignments
            Route::put('/{user}/roles', [UserController::class, 'assignRoles']);
            Route::put('/{user}/adviser', [UserController::class, 'assignAdviser']);
            Route::put('/{user}/sections', [UserController::class, 'assignSections']);
            Route::put('/{user}/status', [UserController::class, 'updateStatus']);
            Route::put('/{user}/cr-status', [UserController::class, 'updateCrStatus']);
        });
    });
});
