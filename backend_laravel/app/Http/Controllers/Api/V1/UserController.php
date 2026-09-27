<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\Complaint;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class UserController extends BaseApiController
{
    /**
     * User Directory Search
     */
    public function index(Request $request): JsonResponse
    {
        $query = User::query();

        if ($request->filled('role')) {
            $query->where('role', $request->role);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('reg_no', 'like', "%{$search}%");
            });
        }

        $users = $query->get()->map(fn(User $u) => $u->toResponseArray())->values()->all();

        return $this->success($users, 'Users retrieved.');
    }

    /**
     * Update Current User Profile
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'fullName' => ['sometimes', 'string', 'max:150'],
            'full_name' => ['sometimes', 'string', 'max:150'],
            'name' => ['sometimes', 'string', 'max:150'],
            'phone' => ['nullable', 'string', 'max:20'],
            'batch' => ['nullable', 'string', 'max:30'],
            'section' => ['nullable', 'string', 'max:10'],
        ]);

        if ($validator->fails()) {
            return $this->error('Validation error', 422, $validator->errors());
        }

        if ($request->filled('fullName') || $request->filled('name') || $request->filled('full_name')) {
            $user->name = $request->fullName ?? $request->name ?? $request->full_name;
        }

        if ($request->has('phone')) $user->phone = $request->phone;
        if ($request->has('batch')) $user->batch = $request->batch;
        if ($request->has('section')) $user->section = strtoupper($request->section);

        $user->save();

        return $this->success($user->toResponseArray(), 'Profile updated successfully.');
    }

    /**
     * Change Password
     */
    public function changePassword(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'currentPassword' => ['required', 'string'],
            'current_password' => ['sometimes', 'string'],
            'newPassword' => ['required', 'string', 'min:8'],
            'new_password' => ['sometimes', 'string', 'min:8'],
        ]);

        if ($validator->fails()) {
            return $this->error('Password validation failed', 422, $validator->errors());
        }

        $user = $request->user();
        $currentPass = $request->currentPassword ?? $request->current_password;
        $newPass = $request->newPassword ?? $request->new_password;

        if (!Hash::check($currentPass, $user->password)) {
            return $this->error('Current password is incorrect.', 400);
        }

        $user->password = Hash::make($newPass);
        $user->save();

        return $this->success(null, 'Password changed successfully.');
    }

    /**
     * Update User Role (Admin only)
     */
    public function updateUserRole(Request $request, string $id): JsonResponse
    {
        $targetUser = User::find($id);
        if (!$targetUser) return $this->error('User not found.', 404);

        $validator = Validator::make($request->all(), [
            'role' => ['required', 'string', 'in:student,cr,batch_adviser,coordinator,chairman,office_staff,dean,admin'],
        ]);

        if ($validator->fails()) {
            return $this->error('Invalid role specified.', 422, $validator->errors());
        }

        $targetUser->role = $request->role;
        $targetUser->save();

        return $this->success($targetUser->toResponseArray(), 'User role updated successfully.');
    }

    /**
     * System Complaint Archives (Admin / Leadership)
     */
    public function archives(): JsonResponse
    {
        $archives = Complaint::with(['student'])
            ->whereIn('status', ['resolved', 'rejected'])
            ->latest()
            ->get()
            ->map(fn(Complaint $c) => $c->toResponseArray())
            ->values()
            ->all();

        return $this->success($archives, 'Archives retrieved.');
    }
}
