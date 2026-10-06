<?php

namespace App\Models;

use App\Concerns\Filterable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasRoles, SoftDeletes, Filterable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'department_id',
        'batch_id',
        'section_id',
        'year',
        'semester',
        'adviser_id',
        'status',
        'phone',
        'profile_image_url',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    public function batch(): BelongsTo
    {
        return $this->belongsTo(Batch::class);
    }

    public function section(): BelongsTo
    {
        return $this->belongsTo(Section::class);
    }

    public function adviser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'adviser_id');
    }

    public function advisees(): HasMany
    {
        return $this->hasMany(User::class, 'adviser_id');
    }

    public function assignedSections(): BelongsToMany
    {
        return $this->belongsToMany(Section::class, 'user_assigned_sections')
            ->withTimestamps();
    }

    public function ApplicationsSubmitted(): HasMany
    {
        return $this->hasMany(Application::class, 'student_id');
    }

    public function ApplicationsAssigned(): HasMany
    {
        return $this->hasMany(Application::class, 'assigned_to_id');
    }

    public function noticesCreated(): HasMany
    {
        return $this->hasMany(Notice::class, 'sender_id');
    }

    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }

    public function media(): \Illuminate\Database\Eloquent\Relations\MorphMany
    {
        return $this->morphMany(Media::class, 'model');
    }

    public function devices(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(UserDevice::class);
    }

    public function loginHistories(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(LoginHistory::class);
    }

    public function getRegistrationNumberAttribute(): string
    {
        if (!empty($this->attributes['registration_number'])) {
            return strtoupper($this->attributes['registration_number']);
        }

        if (!empty($this->email) && str_contains($this->email, '@')) {
            return strtoupper(explode('@', $this->email)[0]);
        }

        return 'N/A';
    }

    public function getBatchDisplayAttribute(): string
    {
        if ($this->relationLoaded('batch') && $this->batch) {
            return $this->batch->name;
        }
        if ($this->batch_id && $b = Batch::find($this->batch_id)) {
            return $b->name;
        }
        if (!empty($this->attributes['batch'])) {
            return $this->attributes['batch'];
        }
        if (!empty($this->year)) {
            return $this->year;
        }
        if (!empty($this->email) && preg_match('/^(\d{2})[a-z]+/i', $this->email, $m)) {
            $yr = (int)$m[1];
            $fullYr = ($yr >= 18 && $yr <= 50) ? (2000 + $yr) : $yr;
            return "Batch {$fullYr}";
        }
        return 'N/A';
    }

    public function getSectionDisplayAttribute(): string
    {
        if ($this->relationLoaded('section') && $this->section) {
            return $this->section->name;
        }
        if ($this->section_id && $s = Section::find($this->section_id)) {
            return $s->name;
        }
        if (!empty($this->attributes['section'])) {
            return $this->attributes['section'];
        }
        if (!empty($this->semester)) {
            return $this->semester;
        }
        return 'N/A';
    }

    // Scopes
    public function scopeStudents($query)
    {
        return $query->role('Student');
    }

    public function scopeCrs($query)
    {
        return $query->role('CR');
    }

    public function scopeApproved($query)
    {
        return $query->where('status', 'approved');
    }
}

