<?php

namespace App\Auth\Middlewares;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SecureHeadersMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        if (method_exists($response, 'header')) {
            $response->header('X-Frame-Options', 'DENY');
            $response->header('X-XSS-Protection', '1; mode=block');
            $response->header('X-Content-Type-Options', 'nosniff');
            $response->header('Referrer-Policy', 'no-referrer-when-downgrade');
            $response->header('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
        }

        return $response;
    }
}
