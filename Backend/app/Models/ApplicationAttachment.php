<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ApplicationAttachment extends Model
{
    use HasFactory;

    protected $fillable = [
        'application_id',
        'file_path',
        'file_name',
        'file_type',
        'file_size',
    ];

    public function Application(): BelongsTo
    {
        return $this->belongsTo(Application::class);
    }
}
