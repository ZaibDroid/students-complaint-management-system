<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AdviserMeetingRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'student_id',
        'adviser_id',
        'reason',
        'status',
        'preferred_slot',
        'adviser_remarks',
    ];

    public function student()
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function adviser()
    {
        return $this->belongsTo(User::class, 'adviser_id');
    }
}
