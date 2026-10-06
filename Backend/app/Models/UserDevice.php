<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserDevice extends Model
{
    protected $guarded = [];

    protected $casts = [
        'refresh_token_expires_at' => 'datetime',
        'last_used_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
