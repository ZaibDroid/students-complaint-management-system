<?php

namespace App\Auth\Middlewares;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureDeviceIsActive
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user) {
            // Find the active device that matches the request's device_id
            $deviceId = $request->header('X-Device-ID') ?? $request->input('device_id');
            
            if ($deviceId) {
                $device = $user->devices()->where('device_id', $deviceId)->first();
                
                if (!$device || $device->revoked_at !== null) {
                    // Revoke current Sanctum token since device is blocked
                    $user->currentAccessToken()->delete();
                    return response()->json(['success' => false, 'message' => 'Your device session has been revoked. Please log in again.'], 401);
                }

                // Update last used randomly to avoid writing to DB on EVERY request, or dispatch a job.
                // For simplicity, we just update it if it's older than 5 minutes.
                if (!$device->last_used_at || $device->last_used_at->diffInMinutes(now()) > 5) {
                    $device->update(['last_used_at' => now(), 'ip_address' => $request->ip()]);
                }
            }
        }

        return $next($request);
    }
}
