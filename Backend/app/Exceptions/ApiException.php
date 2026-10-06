<?php

namespace App\Exceptions;

use Exception;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

class ApiException extends Exception
{
    protected int $statusCode;
    protected mixed $errors;

    public function __construct(
        string $message = 'An API error occurred',
        int $statusCode = Response::HTTP_BAD_REQUEST,
        mixed $errors = null,
        Exception $previous = null
    ) {
        parent::__construct($message, $statusCode, $previous);
        $this->statusCode = $statusCode;
        $this->errors = $errors;
    }

    public function render(): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => $this->getMessage(),
            'data' => null,
            'errors' => $this->errors,
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ], $this->statusCode);
    }
}
