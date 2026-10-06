<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class NoticeAttachment extends Model
{
    use HasFactory;

    protected $fillable = [
        'notice_id',
        'file_name',
        'file_path',
        'file_type',
        'file_size',
    ];

    public function notice()
    {
        return $this->belongsTo(Notice::class);
    }
}
