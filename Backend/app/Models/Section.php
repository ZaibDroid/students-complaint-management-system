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

    public function resolveRouteBinding($value, $field = null)
    {
        if (is_numeric($value)) {
            return $this->where('id', $value)->first() ?? abort(404);
        }

        $batch = request('batch') ?? request('batch_id') ?? request('semester');
        $query = $this->where(function ($q) use ($value) {
            $q->where('name', $value)
              ->orWhere('name', 'Section ' . $value)
              ->orWhere('name', str_replace('Section ', '', $value));
        });

        if ($batch) {
            $query->whereHas('batch', function ($q) use ($batch) {
                if (is_numeric($batch)) {
                    $q->where('id', $batch)->orWhere('name', (string)$batch)->orWhere('start_year', (int)$batch);
                } else {
                    $q->where('name', $batch);
                }
            });
        }

        return $query->first() ?? $this->where('name', $value)->first() ?? abort(404);
    }
}
