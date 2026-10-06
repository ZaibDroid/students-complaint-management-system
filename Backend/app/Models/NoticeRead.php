<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NoticeRead extends Model
{
    use HasFactory;

    protected $fillable = [
        'notice_id',
        'user_id',
        'read_at',
    ];

    protected $casts = [
        'read_at' => 'datetime',
    ];

    public function notice()
    {
        return $this->belongsTo(Notice::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
