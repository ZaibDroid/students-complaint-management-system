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
        'student_id',
        'assigned_to_id',
        'title',
        'description',
        'category_id',
        'status',
        'priority',
        'admin_remarks',
        'attachment_path',
        'attachment_name',
        'attachment_type',
        'attachment_size',
    ];

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
                $latest = static::withTrashed()->latest('id')->first();
                $nextId = $latest ? $latest->id + 1 : 1;
                $application->ticket_number = sprintf('DCMS-%s-%04d', $year, $nextId);
            }
        });
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
