<?php

namespace App\Models;

use App\Concerns\Filterable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use App\Enums\NotificationType;

class Notification extends Model
{
    use HasFactory, Filterable;

    protected $fillable = [
        'user_id',
        'type',
        'reference_type',
        'reference_id',
        'title',
        'message',
        'read_at',
    ];

    protected $casts = [
        'type' => NotificationType::class,
        'read_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function reference(): MorphTo
    {
        return $this->morphTo();
    }

    public function scopeUnread($query)
    {
        return $query->whereNull('read_at');
    }

    public function scopeRecent($query)
    {
        return $query->latest();
    }
}
