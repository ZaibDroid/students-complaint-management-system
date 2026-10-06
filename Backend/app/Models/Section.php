<?php

namespace App\Models;

use App\Concerns\Filterable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Section extends Model
{
    use HasFactory, Filterable, SoftDeletes;

    protected $fillable = [
        'batch_id',
        'name',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function batch(): BelongsTo
    {
        return $this->belongsTo(Batch::class);
    }

    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    public function assignedStaff(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_assigned_sections')
            ->withTimestamps();
    }
}
