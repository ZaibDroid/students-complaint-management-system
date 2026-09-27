<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\BatchController;
use App\Http\Controllers\Api\V1\ComplaintController;
use App\Http\Controllers\Api\V1\DashboardController;
use App\Http\Controllers\Api\V1\NoticeController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\UserController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes for DCMS UET Mardan (v1)
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // ==========================================
    // Public Authentication Endpoints
    // ==========================================
    Route::prefix('auth')->group(function () {
        Route::post('/login', [AuthController::class, 'login']);
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    });

    // ==========================================
    // Protected Routes (Sanctum Auth Required)
    // ==========================================
    Route::middleware('auth:sanctum')->group(function () {

        // Auth & Profile Management
        Route::prefix('auth')->group(function () {
            Route::post('/verify-email', [AuthController::class, 'verifyEmail']);
            Route::post('/resend-verification', [AuthController::class, 'resendVerification']);
            Route::post('/complete-profile', [AuthController::class, 'completeProfile']);
            Route::get('/user', [AuthController::class, 'currentUser']);
            Route::post('/logout', [AuthController::class, 'logout']);
        });

        // User Profile & Settings
        Route::prefix('user')->group(function () {
            Route::put('/profile', [UserController::class, 'updateProfile']);
            Route::post('/change-password', [UserController::class, 'changePassword']);
        });

        // Dashboard & Analytics
        Route::prefix('dashboard')->group(function () {
            Route::get('/stats', [DashboardController::class, 'stats']);
            Route::get('/analytics', [DashboardController::class, 'analytics']);
        });

        // Complaints Workflow
        Route::prefix('complaints')->group(function () {
            Route::get('/', [ComplaintController::class, 'index']);
            Route::get('/my', [ComplaintController::class, 'myComplaints']);
            Route::post('/', [ComplaintController::class, 'store']);
            Route::get('/{id}', [ComplaintController::class, 'show']);
            Route::post('/{id}/forward', [ComplaintController::class, 'forward']);
            Route::post('/{id}/resolve', [ComplaintController::class, 'resolve']);
            Route::post('/{id}/reject', [ComplaintController::class, 'reject']);
            Route::post('/{id}/return', [ComplaintController::class, 'returnBack']);
            Route::post('/{id}/remarks', [ComplaintController::class, 'addRemark']);
            Route::get('/{id}/timeline', [ComplaintController::class, 'timeline']);
        });

        // Notice Board
        Route::prefix('notices')->group(function () {
            Route::get('/', [NoticeController::class, 'index']);
            Route::post('/', [NoticeController::class, 'store']);
            Route::get('/{id}', [NoticeController::class, 'show']);
            Route::delete('/{id}', [NoticeController::class, 'destroy']);
        });

        // Notifications & FCM Device Tokens
        Route::prefix('notifications')->group(function () {
            Route::get('/', [NotificationController::class, 'index']);
            Route::put('/{id}/read', [NotificationController::class, 'markAsRead']);
            Route::put('/read-all', [NotificationController::class, 'markAllRead']);
            Route::post('/fcm-token', [NotificationController::class, 'registerFcmToken']);
        });

        // Academic Batches, Sections & Advisers
        Route::get('/batches', [BatchController::class, 'index']);
        Route::get('/sections', [BatchController::class, 'sections']);
        Route::get('/advisers', [BatchController::class, 'advisers']);
        Route::post('/advisers/request', [BatchController::class, 'requestAdviser']);

        // Admin Management
        Route::prefix('admin')->group(function () {
            Route::get('/users', [UserController::class, 'index']);
            Route::put('/users/{id}/role', [UserController::class, 'updateUserRole']);
            Route::get('/archives', [UserController::class, 'archives']);
        });
    });
});
