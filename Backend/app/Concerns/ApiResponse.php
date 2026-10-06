<?php

namespace App\Concerns;

use Illuminate\Http\JsonResponse;
use Illuminate\Pagination\LengthAwarePaginator;
use Symfony\Component\HttpFoundation\Response;

trait ApiResponse
{
    /**
     * Return a standardized success JSON response.
     */
    protected function successResponse(mixed $data = null, string $message = 'Operation successful', int $code = Response::HTTP_OK): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data,
            'errors' => null,
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ], $code);
    }

    /**
     * Return a standardized created JSON response (201).
     */
    protected function createdResponse(mixed $data = null, string $message = 'Resource created successfully'): JsonResponse
    {
        return $this->successResponse($data, $message, Response::HTTP_CREATED);
    }

    /**
     * Return a standardized paginated JSON response.
     */
    protected function paginatedResponse(LengthAwarePaginator $paginator, string $message = 'Data retrieved successfully'): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $paginator->items(),
            'errors' => null,
            'meta' => [
                'pagination' => [
                    'total' => $paginator->total(),
                    'count' => $paginator->count(),
                    'per_page' => $paginator->perPage(),
                    'current_page' => $paginator->currentPage(),
                    'total_pages' => $paginator->lastPage(),
                    'has_more_pages' => $paginator->hasMorePages(),
                ],
                'timestamp' => now()->toIso8601String(),
            ],
        ], Response::HTTP_OK);
    }

    /**
     * Return a standardized error JSON response.
     */
    protected function errorResponse(string $message = 'An error occurred', int $code = Response::HTTP_BAD_REQUEST, mixed $errors = null): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'data' => null,
            'errors' => $errors,
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ], $code);
    }

    /**
     * Return an unauthorized response (401).
     */
    protected function unauthorizedResponse(string $message = 'Unauthenticated access'): JsonResponse
    {
        return $this->errorResponse($message, Response::HTTP_UNAUTHORIZED);
    }

    /**
     * Return a forbidden response (403).
     */
    protected function forbiddenResponse(string $message = 'Access forbidden'): JsonResponse
    {
        return $this->errorResponse($message, Response::HTTP_FORBIDDEN);
    }

    /**
     * Return a not found response (404).
     */
    protected function notFoundResponse(string $message = 'Resource not found'): JsonResponse
    {
        return $this->errorResponse($message, Response::HTTP_NOT_FOUND);
    }
}
