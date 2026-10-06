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
        'sender_id',
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

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
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
        return $this->targets->firstWhere('target_type', $type)?->target_value;
    }

    public function getTargetValues(string $type): ?array
    {
        $values = $this->targets->where('target_type', $type)->pluck('target_value')->filter()->values()->toArray();
        return !empty($values) ? $values : null;
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
