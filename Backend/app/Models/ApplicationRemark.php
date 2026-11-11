<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ApplicationRemark extends Model
{
    use HasFactory;

    protected $fillable = [
        'application_id',
        'user_id',
        'remark',
    ];

    public function getActionTakenAttribute(): ?string
    {
        return $this->attributes['action_taken'] ?? null;
    }

    public function Application(): BelongsTo
    {
        return $this->belongsTo(Application::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
