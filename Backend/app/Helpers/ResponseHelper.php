<?php

if (!function_exists('api_response')) {
    /**
     * Helper to return standard API Json Response
     */
    function api_response(mixed $data = null, string $message = 'Success', int $code = 200, mixed $errors = null)
    {
        return response()->json([
            'success' => $code >= 200 && $code < 300,
            'message' => $message,
            'data' => $data,
            'errors' => $errors,
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ], $code);
    }
}
