<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Batch extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'year',
        'adviser_id',
    ];

    public function adviser()
    {
        return $this->belongsTo(User::class, 'adviser_id');
    }

    public function sections()
    {
        return $this->hasMany(Section::class, 'batch_id');
    }

    public function students()
    {
        return $this->hasMany(User::class, 'batch', 'name');
    }

    public function toResponseArray(): array
    {
        return [
            'id' => (string) $this->id,
            'name' => $this->name,
            'sessionName' => $this->name,
            'year' => $this->year,
            'adviserId' => $this->adviser_id ? (string) $this->adviser_id : null,
            'adviserName' => $this->adviser?->name ?? 'Unassigned',
            'adviserEmail' => $this->adviser?->email,
            'sections' => $this->sections->pluck('name')->toArray(),
            'totalStudents' => $this->students()->count(),
        ];
    }
}
