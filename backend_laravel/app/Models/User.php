<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'role',
        'password',
        'reg_no',
        'batch',
        'section',
        'phone',
        'avatar',
        'otp',
        'otp_expires_at',
        'email_verified_at',
        'is_profile_completed',
        'fcm_token',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'otp',
        'otp_expires_at',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'otp_expires_at' => 'datetime',
            'is_profile_completed' => 'boolean',
            'password' => 'hashed',
        ];
    }

    // Role checks
    public function isStudent(): bool
    {
        return in_array($this->role, ['student', 'cr']);
    }

    public function isBatchAdviser(): bool
    {
        return $this->role === 'batch_adviser';
    }

    public function isCoordinator(): bool
    {
        return $this->role === 'coordinator';
    }

    public function isChairman(): bool
    {
        return $this->role === 'chairman';
    }

    public function isStaff(): bool
    {
        return in_array($this->role, ['batch_adviser', 'coordinator', 'chairman', 'office_staff', 'dean', 'admin']);
    }

    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    // Relationships
    public function complaints()
    {
        return $this->hasMany(Complaint::class, 'student_id');
    }

    public function advisedBatches()
    {
        return $this->hasMany(Batch::class, 'adviser_id');
    }

    public function notifications()
    {
        return $this->hasMany(AppNotification::class, 'user_id')->latest();
    }

    public function toResponseArray(): array
    {
        return [
            'id' => (string) $this->id,
            'fullName' => $this->name,
            'name' => $this->name,
            'email' => $this->email,
            'role' => $this->role,
            'regNo' => $this->reg_no,
            'reg_no' => $this->reg_no,
            'batch' => $this->batch,
            'section' => $this->section,
            'phone' => $this->phone,
            'avatarUrl' => $this->avatar ? (str_starts_with($this->avatar, 'http') ? $this->avatar : url('storage/' . $this->avatar)) : null,
            'isEmailVerified' => $this->email_verified_at !== null,
            'isProfileCompleted' => (bool) $this->is_profile_completed,
            'createdAt' => $this->created_at?->toIso8601String(),
        ];
    }
}
