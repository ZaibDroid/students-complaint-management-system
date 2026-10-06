<?php

namespace App\Concerns;

use Illuminate\Database\Eloquent\Builder;

trait Filterable
{
    /**
     * Scope a query to apply dynamic filters.
     *
     * @param Builder $query
     * @param array $filters Array of key => value filter criteria
     * @return Builder
     */
    public function scopeFilter(Builder $query, array $filters): Builder
    {
        foreach ($filters as $field => $value) {
            if ($value === null || $value === '') {
                continue;
            }

            if (method_exists($this, 'scope' . ucfirst($field))) {
                $query->{$field}($value);
            } else {
                $query->where($field, $value);
            }
        }

        return $query;
    }
}
