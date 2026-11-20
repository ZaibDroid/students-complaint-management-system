<?php

namespace App\Models;

use App\Concerns\Filterable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Application extends Model
{
    use HasFactory, SoftDeletes, Filterable;

    // Status Constants
    public const STATUS_PENDING = 'pending';
    public const STATUS_FORWARDED = 'forwarded';
    public const STATUS_RESOLVED = 'resolved';
    public const STATUS_REJECTED = 'rejected';
    public const STATUS_RETURNED = 'returned';

    protected $fillable = [
        'ticket_number',
        'department_id',
        'student_id',
        'assigned_to_id',
        'title',
        'description',
        'category_id',
        'status',
        'priority',
    ];

    public function getAdminRemarksAttribute(): ?string
    {
        if (array_key_exists('admin_remarks', $this->attributes) && $this->attributes['admin_remarks']) {
            return $this->attributes['admin_remarks'];
        }

        return $this->remarks()->latest('id')->value('remark');
    }

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($application) {
            if (empty($application->ticket_number)) {
                $year = date('Y');
                $application->ticket_number = sprintf('DCMS-%s-%s', $year, strtoupper(\Illuminate\Support\Str::random(6)));
            }
            if (empty($application->department_id) && !empty($application->student_id)) {
                $studentDeptId = User::where('id', $application->student_id)->value('department_id');
                if ($studentDeptId) {
                    $application->department_id = $studentDeptId;
                }
            }
        });
    }

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    public function attachments(): HasMany
    {
        return $this->hasMany(ApplicationAttachment::class);
    }

    public function media(): \Illuminate\Database\Eloquent\Relations\MorphMany
    {
        return $this->morphMany(Media::class, 'model');
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(ApplicationCategory::class, 'category_id');
    }

    public function assignedTo(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_to_id');
    }


    public function remarks(): HasMany
    {
        return $this->hasMany(ApplicationRemark::class);
    }

    public function timeline(): HasMany
    {
        return $this->hasMany(ApplicationTimeline::class);
    }

    /**
     * Resolve the authoritative assigned Coordinator for this complaint.
     * Complaint -> Student -> Section -> Batch -> Coordinator (batches.coordinator_id)
     */
    public function getAssignedCoordinator(): ?User
    {
        $student = $this->relationLoaded('student')
            ? $this->student
            : $this->student()->with(['section.batch.coordinator', 'batch.coordinator'])->first();

        if (!$student) {
            return null;
        }

        // 1. Through student's assigned section -> batch -> coordinator
        if ($student->section_id) {
            $section = $student->relationLoaded('section') ? $student->section : $student->section()->with('batch.coordinator')->first();
            if ($section && $section->batch_id) {
                $secBatch = $section->relationLoaded('batch') ? $section->batch : $section->batch()->with('coordinator')->first();
                if ($secBatch && $secBatch->coordinator_id) {
                    $coord = $secBatch->relationLoaded('coordinator') ? $secBatch->coordinator : User::find($secBatch->coordinator_id);
                    if ($coord && !$coord->trashed() && $coord->hasRole('Coordinator')) {
                        return $coord;
                    }
                }
            }
        }

        // 2. Through student's direct batch_id -> batch -> coordinator
        if ($student->batch_id) {
            $batch = $student->relationLoaded('batch') ? $student->batch : Batch::with('coordinator')->find($student->batch_id);
            if ($batch && $batch->coordinator_id) {
                $coord = $batch->relationLoaded('coordinator') ? $batch->coordinator : User::find($batch->coordinator_id);
                if ($coord && !$coord->trashed() && $coord->hasRole('Coordinator')) {
                    return $coord;
                }
            }
        }

        return null;
    }

    /**
     * Determine if a Batch Adviser is authorized for this complaint.
     * Adviser must be assigned to complaint OR student belongs to adviser's assigned sections.
     */
    public function isAdviserAuthorized(User $adviser): bool
    {
        $student = $this->relationLoaded('student') ? $this->student : $this->student()->first();
        if (!$student) {
            return false;
        }

        // Section match via assignedSections or direct section_id
        if (!empty($student->section_id)) {
            if (!empty($adviser->section_id) && (int)$student->section_id === (int)$adviser->section_id) {
                return true;
            }
            if ($adviser->assignedSections()->where('sections.id', $student->section_id)->exists()) {
                return true;
            }
        }

        // Explicit adviser link
        if (!empty($student->adviser_id) && (int)$student->adviser_id === (int)$adviser->id) {
            return true;
        }

        return false;
    }

    // Scopes
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeForwarded($query)
    {
        return $query->where('status', 'forwarded');
    }

    public function scopeResolved($query)
    {
        return $query->where('status', 'resolved');
    }

    public function scopeRejected($query)
    {
        return $query->where('status', 'rejected');
    }

    public function scopeReturned($query)
    {
        return $query->where('status', self::STATUS_RETURNED);
    }

    public function scopeForDepartment($query, int $departmentId)
    {
        return $query->where('department_id', $departmentId);
    }

    /**
     * Define valid state transitions.
     */
    public function isValidTransition(string $newStatus): bool
    {
        $validTransitions = [
            self::STATUS_PENDING => [self::STATUS_FORWARDED, self::STATUS_RESOLVED, self::STATUS_REJECTED, self::STATUS_RETURNED],
            self::STATUS_FORWARDED => [self::STATUS_FORWARDED, self::STATUS_RESOLVED, self::STATUS_REJECTED, self::STATUS_RETURNED],
            self::STATUS_RETURNED => [self::STATUS_PENDING], // Once returned, student can submit again (goes to pending)
            self::STATUS_RESOLVED => [], // Terminal state (usually)
            self::STATUS_REJECTED => [], // Terminal state
        ];

        $allowed = $validTransitions[$this->status] ?? [];
        return in_array($newStatus, $allowed);
    }
}
