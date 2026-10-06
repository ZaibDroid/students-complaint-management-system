<?php

namespace App\Auth\Services;

use App\Models\LoginHistory;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;

class AuthService
{
    /**
     * Validate user credentials.
     */
    public function validateCredentials(string $emailOrRegNumber, string $password): ?User
    {
        $user = User::where('email', $emailOrRegNumber)
                    ->orWhere('registration_number', $emailOrRegNumber)
                    ->first();

        if ($user && Hash::check($password, $user->password)) {
            return $user;
        }

        return null;
    }

    /**
     * Record a login attempt (success or failure).
     */
    public function recordLoginAttempt(?User $user, string $ip, string $device, string $platform, bool $success, ?string $failureReason = null): void
    {
        if (!$user) {
            // If user is null, we can't tie it to a user_id. In a real system, you might log failed attempts by IP.
            return; 
        }

        LoginHistory::create([
            'user_id' => $user->id,
            'ip' => $ip,
            'device' => $device,
            'platform' => $platform,
            'success' => $success,
            'failure_reason' => $failureReason,
            'login_at' => now(),
        ]);
    }

    /**
     * Generate and store a 6-digit OTP for password reset.
     */
    public function generatePasswordResetOTP(string $email): string
    {
        $otp = (string) random_int(100000, 999999);

        // UPSERT the token
        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $email],
            [
                'token' => Hash::make($otp),
                'attempts' => 0,
                'created_at' => now(),
            ]
        );

        return $otp;
    }

    /**
     * Validate the OTP for a given email.
     */
    public function validatePasswordResetOTP(string $email, string $otp): bool
    {
        $record = DB::table('password_reset_tokens')->where('email', $email)->first();

        if (!$record) {
            return false;
        }

        // Check expiration (10 minutes)
        if (\Carbon\Carbon::parse($record->created_at)->addMinutes(10)->isPast()) {
            DB::table('password_reset_tokens')->where('email', $email)->delete();
            return false;
        }

        // Check max attempts
        if ($record->attempts >= 5) {
            return false;
        }

        if (Hash::check($otp, $record->token)) {
            // Valid OTP
            DB::table('password_reset_tokens')->where('email', $email)->delete();
            return true;
        }

        // Increment attempts
        DB::table('password_reset_tokens')
            ->where('email', $email)
            ->increment('attempts');

        return false;
    }
}
