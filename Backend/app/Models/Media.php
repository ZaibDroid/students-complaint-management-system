<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Media extends Model
{
    use SoftDeletes;

    protected $guarded = [];

    protected $casts = [
        'size' => 'integer',
        'width' => 'integer',
        'height' => 'integer',
        'duration' => 'integer',
    ];

    /**
     * Get the parent model (Application, Notice, User, etc.).
     */
    public function model(): MorphTo
    {
        return $this->morphTo();
    }

    /**
     * Get the user who uploaded the media.
     */
    public function uploader(): BelongsTo
    {
        return $this->belongsTo(User::class, 'uploaded_by');
    }

    /**
     * Build the download route.
     */
    public function getDownloadUrlAttribute(): string
    {
        return route('api.media.download', ['media' => $this->id]);
    }
}
