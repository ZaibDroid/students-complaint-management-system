<?php

namespace App\Models;

use App\Concerns\Filterable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Notice extends Model
{
    use HasFactory, SoftDeletes, Filterable;

    public const STATUS_DRAFT = 'draft';
    public const STATUS_PUBLISHED = 'published';
    public const STATUS_SCHEDULED = 'scheduled';
    public const STATUS_EXPIRED = 'expired';

    protected $fillable = [
        'department_id',
        'sender_id',
        'target_batch_id',
        'target_section_id',
        'target_role',
        'title',
        'description',
        'tag',
        'status',
        'published_at',
        'scheduled_at',
        'expires_at',
        'version',
    ];

    protected $casts = [
        'published_at' => 'datetime',
        'scheduled_at' => 'datetime',
        'expires_at' => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($notice) {
            if (!array_key_exists('department_id', $notice->getAttributes()) && !empty($notice->sender_id)) {
                $senderDeptId = User::where('id', $notice->sender_id)->value('department_id');
                if ($senderDeptId) {
                    $notice->department_id = $senderDeptId;
                }
            }
            if (empty($notice->status)) {
                $notice->status = self::STATUS_PUBLISHED;
            }
            if (empty($notice->published_at) && $notice->status === self::STATUS_PUBLISHED) {
                $notice->published_at = now();
            }
        });
    }

    public function scopePublished($query)
    {
        return $query->where('status', self::STATUS_PUBLISHED);
    }

    public function scopeForDepartment($query, int $departmentId)
    {
        return $query->where(function ($q) use ($departmentId) {
            $q->whereNull('department_id')
              ->orWhere('department_id', $departmentId);
        });
    }

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function targetBatch(): BelongsTo
    {
        return $this->belongsTo(Batch::class, 'target_batch_id');
    }

    public function targetSection(): BelongsTo
    {
        return $this->belongsTo(Section::class, 'target_section_id');
    }

    public function media(): \Illuminate\Database\Eloquent\Relations\MorphMany
    {
        return $this->morphMany(Media::class, 'model');
    }

    public function targets(): HasMany
    {
        return $this->hasMany(NoticeTarget::class);
    }

    public function attachments(): HasMany
    {
        return $this->hasMany(NoticeAttachment::class);
    }

    public function reads(): HasMany
    {
        return $this->hasMany(NoticeRead::class);
    }

    public function getTargetValue(string $type): ?string
    {
        if ($type === 'crs_only') {
            return $this->target_role === 'CR' ? 'true' : 'false';
        }
        if ($type === 'year' && $this->target_batch_id) {
            return (string)$this->target_batch_id;
        }

        if (\Illuminate\Support\Facades\Schema::hasTable('notice_targets') && $this->relationLoaded('targets')) {
            return $this->targets->firstWhere('target_type', $type)?->target_value;
        }

        return null;
    }

    public function getTargetValues(string $type): ?array
    {
        if ($type === 'batch' && $this->target_batch_id) {
            return [(string)$this->target_batch_id];
        }
        if ($type === 'section' && $this->target_section_id) {
            return [(string)$this->target_section_id];
        }
        if ($type === 'role' && $this->target_role) {
            return [$this->target_role];
        }

        if (\Illuminate\Support\Facades\Schema::hasTable('notice_targets') && $this->relationLoaded('targets')) {
            $values = $this->targets->where('target_type', $type)->pluck('target_value')->filter()->values()->toArray();
            return !empty($values) ? $values : null;
        }

        return null;
    }

    public function isPublished(): bool
    {
        return $this->status === self::STATUS_PUBLISHED;
    }

    public function isExpired(): bool
    {
        return $this->status === self::STATUS_EXPIRED;
    }
}
