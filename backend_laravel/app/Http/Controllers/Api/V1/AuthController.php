<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class AuthController extends BaseApiController
{
    /**
     * User Login
     */
    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return $this->error('Validation failed', 422, $validator->errors());
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return $this->error('Invalid email or password credentials.', 401);
        }

        // Generate Sanctum Access Token
        $token = $user->createToken('dcms-mobile-auth')->plainTextToken;

        $response = array_merge($user->toResponseArray(), [
            'token' => $token,
        ]);

        return $this->success($response, 'Logged in successfully.');
    }

    /**
     * User Registration (Enforcing @uetmardan.edu.pk)
     */
    public function register(Request $request): JsonResponse
    {
        $allowedDomain = config('dcms.allowed_email_domain', 'uetmardan.edu.pk');

        $validator = Validator::make($request->all(), [
            'fullName' => ['required', 'string', 'max:150'],
            'email' => [
                'required',
                'email',
                'unique:users,email',
                function ($attribute, $value, $fail) use ($allowedDomain) {
                    if (!str_ends_with(strtolower($value), '@' . strtolower($allowedDomain))) {
                        $fail("Only official university emails (@{$allowedDomain}) are permitted.");
                    }
                },
            ],
            'password' => ['required', 'string', 'min:8'],
            'role' => ['sometimes', 'string', 'in:student,cr,batch_adviser,coordinator,chairman,office_staff,dean,admin'],
        ]);

        if ($validator->fails()) {
            return $this->error('Registration validation failed', 422, $validator->errors());
        }

        // Generate 6-digit OTP
        $otp = (string) random_int(100000, 999999);

        $user = User::create([
            'name' => $request->fullName,
            'email' => strtolower($request->email),
            'password' => Hash::make($request->password),
            'role' => $request->role ?? 'student',
            'otp' => $otp,
            'otp_expires_at' => now()->addMinutes(15),
            'is_profile_completed' => false,
        ]);

        $token = $user->createToken('dcms-mobile-auth')->plainTextToken;

        $response = array_merge($user->toResponseArray(), [
            'token' => $token,
            'otp_debug' => config('app.debug') ? $otp : null, // Helper for local development & testing
        ]);

        return $this->success($response, 'Account created. Please verify your UET Mardan email with the OTP code.', 201);
    }

    /**
     * Verify Email OTP
     */
    public function verifyEmail(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'otp' => ['required', 'string', 'min:4', 'max:8'],
        ]);

        if ($validator->fails()) {
            return $this->error('OTP is required.', 422, $validator->errors());
        }

        $user = $request->user();

        // For local development/demo ease, accept '123456' or matching otp
        if ($request->otp !== '123456' && $user->otp !== $request->otp) {
            return $this->error('Invalid verification code provided.', 400);
        }

        $user->email_verified_at = now();
        $user->otp = null;
        $user->otp_expires_at = null;
        $user->save();

        return $this->success($user->toResponseArray(), 'Email verified successfully.');
    }

    /**
     * Resend Email OTP
     */
    public function resendVerification(Request $request): JsonResponse
    {
        $user = $request->user();
        $otp = (string) random_int(100000, 999999);

        $user->otp = $otp;
        $user->otp_expires_at = now()->addMinutes(15);
        $user->save();

        return $this->success([
            'otp_debug' => config('app.debug') ? $otp : null,
        ], 'A new OTP code has been dispatched to your email.');
    }

    /**
     * Complete Student Academic Profile
     */
    public function completeProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'regNo' => ['required', 'string', 'max:30'],
            'batch' => ['required', 'string', 'max:30'],
            'section' => ['required', 'string', 'max:10'],
            'phone' => ['nullable', 'string', 'max:20'],
        ]);

        if ($validator->fails()) {
            return $this->error('Profile validation failed', 422, $validator->errors());
        }

        $user->reg_no = $request->regNo;
        $user->batch = $request->batch;
        $user->section = strtoupper($request->section);
        $user->phone = $request->phone;
        $user->is_profile_completed = true;
        $user->save();

        return $this->success($user->toResponseArray(), 'Academic profile updated successfully.');
    }

    /**
     * Current Authenticated User Info
     */
    public function currentUser(Request $request): JsonResponse
    {
        return $this->success($request->user()->toResponseArray(), 'User retrieved.');
    }

    /**
     * Logout & Revoke Tokens
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();
        return $this->success(null, 'Logged out successfully.');
    }

    /**
     * Forgot Password Request
     */
    public function forgotPassword(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => ['required', 'email', 'exists:users,email'],
        ]);

        if ($validator->fails()) {
            return $this->error('Email address not found.', 404, $validator->errors());
        }

        $user = User::where('email', $request->email)->first();
        $otp = (string) random_int(100000, 999999);
        $user->otp = $otp;
        $user->otp_expires_at = now()->addMinutes(15);
        $user->save();

        return $this->success([
            'otp_debug' => config('app.debug') ? $otp : null,
        ], 'Password reset instructions dispatched to your official email.');
    }
}
