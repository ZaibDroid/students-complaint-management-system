<?php

namespace App\Models;

use App\Concerns\Filterable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Batch extends Model
{
    use HasFactory, SoftDeletes, Filterable;

    protected $fillable = [
        'department_id',
        'coordinator_id',
        'name',
        'start_year',
        'end_year',
        'is_active',
    ];

    protected $casts = [
        'coordinator_id' => 'integer',
        'start_year' => 'integer',
        'end_year' => 'integer',
        'is_active' => 'boolean',
    ];

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    public function coordinator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'coordinator_id');
    }

    public function sections(): HasMany
    {
        return $this->hasMany(Section::class);
    }

    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeUnassignedCoordinator($query)
    {
        return $query->whereNull('coordinator_id');
    }

    public function scopeHasActiveCoordinator($query)
    {
        return $query->whereNotNull('coordinator_id')
            ->whereHas('coordinator', function ($q) {
                $q->whereNull('deleted_at')
                  ->whereHas('roles', function ($rq) {
                      $rq->where('name', 'Coordinator');
                  });
            });
    }

    public function hasActiveCoordinator(): bool
    {
        if (empty($this->coordinator_id)) {
            return false;
        }
        $coord = $this->relationLoaded('coordinator') ? $this->coordinator : $this->coordinator()->first();
        if (!$coord || $coord->trashed()) {
            return false;
        }
        return $coord->hasRole('Coordinator');
    }

    public function scopeAvailableForCoordinator($query, $coordinatorUserId = null)
    {
        return $query->where(function ($q) use ($coordinatorUserId) {
            $q->whereNull('coordinator_id');
            if (!empty($coordinatorUserId) && is_numeric($coordinatorUserId)) {
                $q->orWhere('coordinator_id', (int)$coordinatorUserId);
            }
        });
    }
}
