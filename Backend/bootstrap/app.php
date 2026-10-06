<?php

use App\Exceptions\ApiException;
use App\Http\Middleware\ForceJsonResponse;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Force Accept: application/json header on all API routes
        $middleware->api(append: [
            ForceJsonResponse::class,
            \App\Auth\Middlewares\SecureHeadersMiddleware::class,
        ]);

        $middleware->alias([
            'device.active' => \App\Auth\Middlewares\EnsureDeviceIsActive::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // Render custom JSON responses for API exceptions

        $exceptions->render(function (ApiException $e, Request $request) {
            return $e->render();
        });

        $exceptions->render(function (ValidationException $e, Request $request) {
            if ($request->is('api/*') || $request->wantsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'data' => null,
                    'errors' => $e->errors(),
                    'meta' => [
                        'timestamp' => now()->toIso8601String(),
                    ],
                ], Response::HTTP_UNPROCESSABLE_ENTITY);
            }
        });

        $exceptions->render(function (AuthenticationException $e, Request $request) {
            if ($request->is('api/*') || $request->wantsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthenticated access',
                    'data' => null,
                    'errors' => null,
                    'meta' => [
                        'timestamp' => now()->toIso8601String(),
                    ],
                ], Response::HTTP_UNAUTHORIZED);
            }
        });

        $exceptions->render(function (AuthorizationException $e, Request $request) {
            if ($request->is('api/*') || $request->wantsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => $e->getMessage() ?: 'This action is unauthorized',
                    'data' => null,
                    'errors' => null,
                    'meta' => [
                        'timestamp' => now()->toIso8601String(),
                    ],
                ], Response::HTTP_FORBIDDEN);
            }
        });

        $exceptions->render(function (ModelNotFoundException|NotFoundHttpException $e, Request $request) {
            if ($request->is('api/*') || $request->wantsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Requested resource not found',
                    'data' => null,
                    'errors' => null,
                    'meta' => [
                        'timestamp' => now()->toIso8601String(),
                    ],
                ], Response::HTTP_NOT_FOUND);
            }
        });

        $exceptions->render(function (Throwable $e, Request $request) {
            if ($request->is('api/*') || $request->wantsJson()) {
                $statusCode = method_exists($e, 'getStatusCode') ? $e->getStatusCode() : Response::HTTP_INTERNAL_SERVER_ERROR;
                $message = config('app.debug') ? $e->getMessage() : 'An internal server error occurred';

                return response()->json([
                    'success' => false,
                    'message' => $message,
                    'data' => null,
                    'errors' => config('app.debug') ? [
                        'file' => $e->getFile(),
                        'line' => $e->getLine(),
                        'trace' => $e->getTraceAsString(),
                    ] : null,
                    'meta' => [
                        'timestamp' => now()->toIso8601String(),
                    ],
                ], $statusCode >= 100 && $statusCode <= 599 ? $statusCode : Response::HTTP_INTERNAL_SERVER_ERROR);
            }
        });
    })->create();
