<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class NoticeTarget extends Model
{
    use HasFactory;

    protected $fillable = [
        'notice_id',
        'target_type',
        'target_value',
    ];

    public function notice(): BelongsTo
    {
        return $this->belongsTo(Notice::class);
    }
}
